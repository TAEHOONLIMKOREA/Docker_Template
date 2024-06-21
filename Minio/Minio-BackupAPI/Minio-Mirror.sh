#!/bin/bash

# 설정
SOURCE_MINIO_URL="http://bigsoft.iptime.org:59000"
SOURCE_ACCESS_KEY="keti_root"
SOURCE_SECRET_KEY="madcoder"
SOURCE_BUCKET="keti"

TARGET_MINIO_URL="http://bigsoft.iptime.org:55420"
TARGET_ACCESS_KEY="keti_root"
TARGET_SECRET_KEY="madcoder"
TARGET_BUCKET="keti"

# mc alias 설정
mc alias set source-minio $SOURCE_MINIO_URL $SOURCE_ACCESS_KEY $SOURCE_SECRET_KEY
mc alias set target-minio $TARGET_MINIO_URL $TARGET_ACCESS_KEY $TARGET_SECRET_KEY

# 대상 버킷 생성
mc mb target-minio/$TARGET_BUCKET 2>/dev/null

# 데이터 복사 및 재시도 로직
RETRIES=100
DELAY=10

for ((i=1; i<=RETRIES; i++)); do
    if mc mirror source-minio/$SOURCE_BUCKET target-minio/$TARGET_BUCKET; then
        echo "Data successfully mirrored on attempt $i."
        break
    else
        echo "Error occurred during mirroring. Attempt $i of $RETRIES failed. Retrying in $DELAY seconds..."
        sleep $DELAY
    fi

    if [ $i -eq $RETRIES ]; then
        echo "Failed to mirror data after $RETRIES attempts."
        exit 1
    fi
done

# 데이터 검증
mc ls source-minio/$SOURCE_BUCKET
mc ls target-minio/$TARGET_BUCKET