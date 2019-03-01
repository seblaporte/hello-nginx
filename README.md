# Hello-Nginx

Simple web site with Nginx based on Alpine Docker image.

## Build

```bash
docker build -t hello-nginx:v1 .
```

## Run

```bash
docker run -p 8080:80 --name hello-nginx hello-nginx:v1
```