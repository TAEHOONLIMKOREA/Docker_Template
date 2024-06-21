#!/bin/bash

# 설정
SOURCE_HOST="bigsoft.iptime.org"
SOURCE_PORT="55432"
SOURCE_DATABASE="keti_pe_3pdx"
SOURCE_USER="keti_superuser"
SOURCE_PASSWORD="madcoder"

TARGET_HOST="bigsoft.iptime.org"
TARGET_PORT="55422"
TARGET_DATABASE="keti_3pdx"
TARGET_USER="keti_root"
TARGET_PASSWORD="madcoder"

DUMP_FILE="sourcedb.dump"
LOG_FILE="restore.log"


export PGPASSWORD=$SOURCE_PASSWORD
pg_dump -h $SOURCE_HOST -p $SOURCE_PORT -U $SOURCE_USER -F c -b -v --clean --no-owner --disable-triggers -f $DUMP_FILE $SOURCE_DATABASE
if [ $? -ne 0 ]; then
  echo "Error creating dump file."
  exit 1
fi
echo "Dump file created successfully."

# 2. 타겟 데이터베이스 존재 여부 확인 및 생성
echo "Checking if target database exists..."
export PGPASSWORD=$TARGET_PASSWORD
DB_EXISTS=$(psql -h $TARGET_HOST -p $TARGET_PORT -U $TARGET_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$TARGET_DATABASE'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "Target database does not exist. Creating target database..."
  psql -h $TARGET_HOST -p $TARGET_PORT -U $TARGET_USER -d postgres -c "CREATE DATABASE $TARGET_DATABASE"
  if [ $? -ne 0 ]; then
    echo "Error creating target database."
    exit 1
  fi
  echo "Target database created successfully."
else
  echo "Target database already exists."
fi

# 3. 타겟 데이터베이스에 덤프 파일 복원
echo "Restoring dump file to target database..."
pg_restore -h $TARGET_HOST -p $TARGET_PORT -U $TARGET_USER -d $TARGET_DATABASE -v --clean $DUMP_FILE &> $LOG_FILE
if [ $? -ne 0 ]; then
  echo "Error restoring dump file. Check the log file for details: $LOG_FILE"
  exit 1
fi
echo "Dump file restored successfully."