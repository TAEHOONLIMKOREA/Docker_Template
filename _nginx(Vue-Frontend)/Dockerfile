# [1] build stage
# 빌드 단계에서 사용할 베이스 이미지로 node:lts-alpine 이미지를 사용.
# 이 이미지는 Node.js가 설치된 Alpine Linux 환경임
FROM node:lts-alpine as build-stage
# 컨테이너 내에서 작업 디렉토리를 /frontend로 설정
WORKDIR /frontend
# 현재 디렉토리의 package.json 및 package-lock.json 파일을 컨테이너의 작업 디렉토리로 복사
COPY package*.json ./
# Node.js 패키지를 설치
RUN npm install
# 현재 디렉토리의 모든 파일을 컨테이너의 작업 디렉토리로 복사
COPY . .
# 프론트엔드 애플리케이션을 빌드
RUN npm run build

# [2] production stage
# 프로덕션 단계에서 사용할 베이스 이미지로 nginx:stable-alpine 이미지를 사용
FROM nginx:stable-alpine as production-stage
# 빌드 단계에서 생성된 정적 파일을 Nginx가 제공하는 기본 디렉토리(/usr/share/nginx/html)로 복사
COPY --from=build-stage /frontend/dist /usr/share/nginx/html
# 컨테이너가 외부에 노출할 포트를 80번으로 지정
EXPOSE 80
# 컨테이너가 시작될 때 실행할 명령을 지정. 
# Nginx를 백그라운드에서 실행하도록 설정
CMD ["nginx", "-g", "daemon off;"]