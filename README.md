# Hello-Nginx

Simple web site with Nginx based on Alpine Docker image.

Contains a Jenkins file to build with Kaniko and deployed with Kubernetes.

## Build

```bash
docker build -t hello-nginx .
```

## Run

```bash
docker run -p 8080:80 --name hello-nginx hello-nginx
```