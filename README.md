# nginx-load-balancer
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

#### Nginx Load Balancer Dockerfile

```
FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

