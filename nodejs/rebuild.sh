podman container stop nodeapp-1 nodeapp-2
podman container prune
podman rmi nodeapp:001
cd /root/superbee.tk/docker/nodejs
podman build -t nodeapp:001 .
podman container run -p 5001:5000 --name nodeapp-1 -d nodeapp:001
podman container run -p 5002:5000 --name nodeapp-2 -e "name=你好啊！！！" -d nodeapp:001
podman ps


