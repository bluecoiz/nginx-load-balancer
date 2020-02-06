## Podman Network Configuration

#### Create Network
```ssh
$ podman network create
/etc/cni/net.d/cni-podman1.conflist
```
Get the name of the network you created. You will need this name to fill in configuration later.
```
$ cat /etc/cni/net.d/cni-podman1.conflist | grep -oP '(?<="name": ")[^"]*'
cni-podman1
```
or
```
$ podman network ls
NAME          VERSION   PLUGINS
podman        0.4.0     bridge,portmap,firewall,tuning
cni-podman1   0.4.0     bridge,portmap,firewall,dnsname
```

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


#### Initialize Node.js Application

1. Change directory to nodejs application path.
```
cd nodejs
```
2. Node.js initialize.
```
npm init
```
3. Install dependencies.
```
npm install express --save
```


#### Build Docker Image and Run Podman Containers
Remember to change the --network name to the network you created just now.
```
cd nodejs
podman build -t nodeapp:001 .
podman container run -p 5001:5000 --network cni-podman1 --name nodeapp-1 -d nodeapp:001
podman container run -p 5002:5000 --network cni-podman1 --name nodeapp-2 -e "name=Bye" -d nodeapp:001
podman ps
```


## Nginx Load Balancer Setup

#### Check Node.js application Podman container IP address.
Check the node app container ip address which created just now.
```
$ podman container inspect nodeapp-1 | grep -oP '(?<="IPAddress": ")[^"]*'
10.88.0.5
$ podman container inspect nodeapp-2 | grep -oP '(?<="IPAddress": ")[^"]*'
10.88.0.6
```

#### nginx.conf
Please update the upstream servers ip address.

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
Remember to change the --network name to the network you created just now.
```
cd nginx
podman build -t nginx-lb:001 .
podman container run -p 5000:80 --network cni-podman1 --name loadbalancer -d nginx-lb:001
```

