# Active Tech DevOps Internship Practice App

A simple web application built with **Node.js**, **Redis**, and **Nginx**.

When accessed, it returns JSON like the following:

```json
{
  "message": "Automate all the things!",
  "hostname": "web1",
  "total_visits": 1,
  "timestamp": 1763130004
}
```


Project structure:
```
├── README.md
├── docker-compose.yml
├── nginx
│   ├── Dockerfile
│   └── nginx.conf
├── terra-config
│   ├── main.tf
└── web
    ├── Dockerfile
    ├── package-lock.json
    ├── package.json
    └── server.js

3 directories, 9 files

```
[_compose.yml_](compose.yml)
```

services:
  redis:
    image: redis
    ports:
      - '6379:6379'
  web1:
    restart: on-failure
    build: ./web
    hostname: web1
    ports:
      - '81:5000'
  web2:
    restart: on-failure
    build: ./web
    hostname: web2
    ports:
      - '82:5000'
  nginx:
    build: ./nginx
    ports:
    - '80:80'
    depends_on:
    - web1
    - web2
```
The compose file defines an application with four services `redis`, `nginx`, `web1` and `web2`.
When deploying the application, Docker compose maps port 80 of the nginx service container to port 80 of the host as specified in the file.


> ℹ**_INFO_**
> Redis runs on port 6379 by default. Make sure port 6379 on the host is not being used by another container, otherwise the port should be changed.

## Deploy with docker compose

```
$ docker compose up -d
[+] Running 24/24
 ⠿ redis Pulled                                                                                                                                                                                                                      ...
   ⠿ 565225d89260 Pull complete
[+] Building 2.4s (22/25)
 => [nginx-nodejs-redis_nginx internal] load build definition from Dockerfile                                                                                                                                                         ...
[+] Running 5/5
 ⠿ Network nginx-nodejs-redis_default    Created
 ⠿ Container nginx-nodejs-redis-web2-1   Started
 ⠿ Container nginx-nodejs-redis-redis-1  Started
 ⠿ Container nginx-nodejs-redis-web1-1   Started
 ⠿ Container nginx-nodejs-redis-nginx-1  Started
```


## Expected result

Listing containers must show three containers running and the port mapping as below:


```
docker compose ps
```

## Testing the app

After the application starts, navigate to `http://localhost:80` in your web browser or run:

```
curl localhost:80
curl localhost:80
{
  "message": "Automate all the things!",
  "hostname": "web1",
  "total_visits": 1,
  "timestamp": 1763131204
}
```

```
curl localhost:80
{
  "message": "Automate all the things!",
  "hostname": "web2",
  "total_visits": 2,
  "timestamp": 1763131004
}
```
```
$ curl localhost:80
{
  "message": "Automate all the things!",
  "hostname": "web1",
  "total_visits": 3,
  "timestamp": 1763130104
}
```



## Tear down the containers

```
$ docker compose down
```
