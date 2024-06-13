FROM mongo:7.0

# 패키지 목록 업데이트 및 vim 설치
RUN apt-get update && apt-get install -y vim

# MongoDB 키 파일 생성 및 권한 설정
RUN openssl rand -base64 756 > /etc/mongo-keyfile
RUN chmod 400 /etc/mongo-keyfile
RUN chown mongodb:mongodb /etc/mongo-keyfile
