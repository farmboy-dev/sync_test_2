#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [TAR_DIR_OR_FILE] [DOCKER_REGISTRY]"
    echo "Load Docker images from tar files in TAR_DIR_OR_FILE, tag them with DOCKER_REGISTRY, and push to the registry."
    echo "Arguments:"
    echo "  TAR_DIR_OR_FILE  Directory containing Docker image tar files or a single tar file."
    echo "  DOCKER_REGISTRY  Docker registry address to tag the images. Example: kubekey.cluster.local/test"
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
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

# Check if TAR_DIR_OR_FILE is a directory or a file
if [ -d "$TAR_DIR_OR_FILE" ]; then
    # If it's a directory, loop through tar files in TAR_DIR
    for tar_file in "$TAR_DIR_OR_FILE"/*.tar; do
        process_tar_file "$tar_file" "$DOCKER_REGISTRY"
    done
elif [ -f "$TAR_DIR_OR_FILE" ]; then
    # If it's a single tar file, process it
    process_tar_file "$TAR_DIR_OR_FILE" "$DOCKER_REGISTRY"
else
    echo "Error: Invalid TAR_DIR_OR_FILE provided."
    show_help
    exit 1
fi

echo "Process completed."

# Function to process a single tar file
process_tar_file() {
    local tar_file="$1"
    local registry="$2"

    # Extract image name from tar file
    local image_name=$(docker inspect --format="{{.RepoTags}}" "$(docker load -i "$tar_file" | awk '{print $NF}' | sed 's/:$//')")

    # Remove 'XXX.io/' from the beginning of the image name
    image_name=$(echo "$image_name" | sed -E 's/^[[:alnum:]]+\.io\///')

    # Tag the image with the Docker registry address
    docker tag "$image_name" "$registry/$image_name"

    # Push the tagged image to the registry
    docker push "$registry/$image_name"

    echo "Image $image_name has been tagged and pushed to $registry."
}
