#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [TAR_DIR_OR_FILE] [DOCKER_REGISTRY]"
    echo "Load Docker images from tar files in TAR_DIR_OR_FILE, tag them with DOCKER_REGISTRY, push to the registry, and optionally remove the local images."
    echo "Arguments:"
    echo "  TAR_DIR_OR_FILE  Directory containing Docker image tar files or a single tar file."
    echo "  DOCKER_REGISTRY  Docker registry address to tag the images. Example: kubekey.cluster.local/test"
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
    echo "  -r, --remove     Remove the local images after pushing to the registry."
}

# Show help if no parameters are provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Handle help option
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
esac

# Check if TAR_DIR_OR_FILE is provided
if [ -e "$1" ]; then
    # Set the directory containing tar files or the tar file itself
    TAR_DIR_OR_FILE="$1"
else
    echo "Error: TAR_DIR_OR_FILE not provided or not a valid path."
    show_help
    exit 1
fi

# Check if DOCKER_REGISTRY is provided
if [ -n "$2" ]; then
    DOCKER_REGISTRY="$2"
else
    echo "Error: DOCKER_REGISTRY not provided."
    show_help
    exit 1
fi

# Check for the remove option
REMOVE_OPTION=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        -r|--remove)
            REMOVE_OPTION=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Loop through tar files in TAR_DIR_OR_FILE
for tar_file in "$TAR_DIR_OR_FILE"/*.tar; do
    # Extract image name from tar file
    image_name=$(docker inspect --format="{{.RepoTags}}" "$(docker load -i "$tar_file" | awk '{print $NF}' | sed 's/:$//')")

    # Remove 'XXX.io/' from the beginning of the image name
    image_name=$(echo "$image_name" | sed -E 's/^[[:alnum:]]+\.io\///')

    # Tag the image with the Docker registry address
    docker tag "$image_name" "$DOCKER_REGISTRY/$image_name"

    # Push the tagged image to the registry
    docker push "$DOCKER_REGISTRY/$image_name"

    echo "Image $image_name has been tagged and pushed to $DOCKER_REGISTRY."

    if [ "$REMOVE_OPTION" = true ]; then
        # Remove the local image
        docker rmi "$image_name"
        echo "Local image $image_name has been removed."
    fi
done

echo "Process completed."

