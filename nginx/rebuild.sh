podman container stop loadbalancer
podman container prune
podman rmi nginx-lb:001
cd /root/superbee.tk/docker/nginx
podman build -t nginx-lb:001 .
podman container run -p 5000:80 --network cni-podman1 --name loadbalancer -d nginx-lb:001
podman ps
