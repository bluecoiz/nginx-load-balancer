## Node.js Application Setup

#### Prerequisites:
Make sure your workstation already install nodejs.


#### app.js
```
const express = require('express')
const app = express()
const port = 5000
const name = process.env.name || "World"

    app.get('/', (req, res) => {
        res.send(`Hello ${name} !`)
    })
app.listen(port, () => {
    console.log(`Server Started on Port  ${port}`)
})
```

#### Dockerfile
```
FROM node:alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD node app.js
EXPOSE 5000
```


#### Setup

1. Change directory to nodejs application path.
```
cd nodejs
```
2. Node.js initialize.
```
npm init
```
3. Install Dependencies.
```
npm install express --save
```


## Nginx Load Balancer Setup
A sample Nginx load balancing on NodeJS application

#### nginx.conf
```nginx
log_format upstreamlog 
    '$server_name to: $upstream_addr [$request] '
    'upstream_response_time $upstream_response_time '
    'msec $msec '
    'request_time $request_time';

upstream appcluster {
    least_conn;
    server 10.88.0.5:5000;
    server 10.88.0.6:5000;
}

server {
    listen 80;
    server_name localhost;

    access_log /var/log/nginx/access.log upstreamlog;

    location / {
        proxy_pass http://appcluster;
    }

    location /favicon.ico {
        access_log off; 
        log_not_found off;
    }
}
```

#### Dockerfile
```
FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

#### Build Docker Image and Run Podman Container
```
podman build -t nginx-lb:001 .
podman container run -p 5000:80 --network cni-podman1 --name loadbalancer -d nginx-lb:001
```

