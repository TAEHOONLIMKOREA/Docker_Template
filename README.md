# DB&Server Template of Docker 

## 1. DB Template

##### 1) 이미지는 도커 허브에서 Pull
######  → Docker Hub에서 각 DB 회사의 공식 이미지 사용 (Official 인증 이미지 사용)
    $ docker pull taehoony/minio:1.3
    $ docker pull taehoony/postgres:1.3
    $ docker pull taehoony/mongo:1.0
    $ docker pull taehoony/redis:1.0
    $ docker pull taehoony/influxdb:1.0

버전 생략시 최신으로 다운로드 됨

##### 2) Docker-compose을 이용해 컨테이너 생성
    $ docker-compose up
    
## 2. WAS Server Template

##### 1) Dockerfile을 통해 이미지를 생성 (기반 이미지 있음)
    $ docker build -t [name]:[tag] [path]
    
##### 2) Docker-compose을 이용해 컨테이너 생성
    $ docker-compose up
