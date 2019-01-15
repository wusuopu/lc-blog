FROM node:8-alpine

COPY ./package.json ./package-lock.json ./yarn.lock /app
WORKDIR /app
RUN npm install

COPY ./patch /app/

RUN patch -p0 < patch/patch1
RUN patch -p0 < patch/patch3
RUN patch -p0 < patch/patch4

EXPOSE 5000
