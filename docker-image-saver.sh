#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 <IMAGE_LIST_FILE> <SAVE_DIR>"
    echo "Download Docker images listed in IMAGE_LIST_FILE, save them as tar files, and remove the images."
    echo "Arguments:"
    echo "  IMAGE_LIST_FILE  Path to the file containing Docker image names."
    echo "  SAVE_DIR         Directory to save Docker images as tar files."
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

# Set the path and filename for the image list
IMAGE_LIST_FILE="$1"

# Set the directory to save images
SAVE_DIR="$2"

# Check for required arguments
if [ -z "$IMAGE_LIST_FILE" ] || [ -z "$SAVE_DIR" ]; then
    echo "Error: Missing required arguments."
    show_help
    exit 1
fi

# Check if the image list file exists
if [ ! -f "$IMAGE_LIST_FILE" ]; then
    echo "Error: IMAGE_LIST_FILE not found."
    exit 1
fi

# Create the save directory
mkdir -p "$SAVE_DIR"

# Read the image list file and download, save, and remove each image
while IFS= read -r image; do
    echo "Processing image: $image"
    
    # Download the image
    docker pull "$image"
    
    # Save the image as a tar file
    docker save -o "$SAVE_DIR/$image.tar" "$image"
    
    # Remove the image
    docker rmi "$image"
    
    echo "Image $image has been saved and removed."
    
done < "$IMAGE_LIST_FILE"

echo "Process completed. Images are saved in $SAVE_DIR directory."

