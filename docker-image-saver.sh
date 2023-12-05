#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [IMAGE_LIST_FILE] [SAVE_DIR]"
    echo "Download Docker images listed in IMAGE_LIST_FILE, save them as tar files, and remove the images."
    echo "Arguments:"
    echo "  IMAGE_LIST_FILE  Path to the file containing Docker image names. If not provided, images can be typed directly."
    echo "  SAVE_DIR         Directory to save Docker images as tar files. If not provided, current working directory will be used."
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
}

# Function to sanitize a string for use as a filename
sanitize_filename() {
    echo "$1" | tr -cd '[:alnum:]._-'
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

# Check if IMAGE_LIST_FILE is provided
if [ -f "$1" ]; then
    # Read the image list from the file
    IMAGE_LIST_FILE="$1"
    SAVE_DIR="${2:-.}"  # Use current working directory if SAVE_DIR is not provided
else
    # Read the image list from the arguments
    IMAGE_LIST_FILE=""
    SAVE_DIR="${1:-.}"  # Use current working directory if SAVE_DIR is not provided
fi

# Create the save directory if it doesn't exist
mkdir -p "$SAVE_DIR"

# Read the image list from either file or arguments
if [ -n "$IMAGE_LIST_FILE" ]; then
    IMAGES=$(cat "$IMAGE_LIST_FILE")
else
    IMAGES="${@:2}"
fi

# Process each image: download, save, and remove
for image in $IMAGES; do
    echo "Processing image: $image"
    
    # Download the image
    docker pull "$image"
    
    # Sanitize the image name to create a valid filename
    sanitized_name=$(sanitize_filename "$image")
    
    # Save the image as a tar file
    docker save -o "$SAVE_DIR/$sanitized_name.tar" "$image"
    
    # Remove the image
    docker rmi "$image"
    
    echo "Image $image has been saved and removed as $sanitized_name.tar."
done

echo "Process completed. Images are saved in $SAVE_DIR directory."
