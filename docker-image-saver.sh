#!/bin/bash

# 도움말 함수
show_help() {
    echo "Usage: $0 <IMAGE_LIST_FILE> <SAVE_DIR>"
    echo "Download Docker images listed in IMAGE_LIST_FILE, save them as tar files, and remove the images."
    echo "Arguments:"
    echo "  IMAGE_LIST_FILE  Path to the file containing Docker image names."
    echo "  SAVE_DIR         Directory to save Docker images as tar files."
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
}

# 파라미터가 없을 때 도움말 출력
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# 도움말 옵션 처리
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
esac

# 이미지 목록 파일을 저장할 경로 및 파일명
IMAGE_LIST_FILE="$1"

# 이미지를 저장할 디렉토리
SAVE_DIR="$2"

# 필수 인자 확인
if [ -z "$IMAGE_LIST_FILE" ] || [ -z "$SAVE_DIR" ]; then
    echo "Error: Missing required arguments."
    show_help
    exit 1
fi

# 이미지 목록 파일이 존재하는지 확인
if [ ! -f "$IMAGE_LIST_FILE" ]; then
    echo "Error: IMAGE_LIST_FILE not found."
    exit 1
fi

# 저장 디렉토리 생성
mkdir -p "$SAVE_DIR"

# 이미지 목록 파일을 읽어서 이미지 다운로드, 저장, 삭제
while IFS= read -r image; do
    echo "Processing image: $image"
    
    # 이미지 다운로드
    docker pull "$image"
    
    # 이미지를 tar로 저장
    docker save -o "$SAVE_DIR/$image.tar" "$image"
    
    # 이미지 삭제
    docker rmi "$image"
    
    echo "Image $image has been saved and removed."
    
done < "$IMAGE_LIST_FILE"

echo "Process completed. Images are saved in $SAVE_DIR directory."
