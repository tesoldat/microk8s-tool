#!/bin/bash
# ask user type in dockerhub credentials
echo "Please type in your dockerhub credentials"
read -r -p "Username: " username
read -r -sp "Token: " token
echo
# check if the credentials are correct
if [ "$(curl -s -o /dev/null -w "%{http_code}" -u $username:$token https://hub.docker.com/v2/users/$username/)" == "200" ]; then
    echo "Login successful"
else
    echo "Login failed"
    exit 1
fi

# clear old credentials
sed -i "/#'plugins.\"io.containerd.grpc.v1.cri\".registry' contains credentials for pulling images from the registry docker.io ./,+3d" /var/snap/microk8s/current/args/containerd-template.toml


# edit /var/snap/microk8s/current/args/containerd-template.toml
{
  echo "#'plugins.\"io.containerd.grpc.v1.cri\".registry' contains credentials for pulling images from the registry docker.io ."
  echo "\[plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"registry-1.docker.io\".auth\]"
  echo "  username = \"$username\""
  echo "  password = \"$token\""
} >> /var/snap/microk8s/current/args/containerd-template.toml

# restart microk8s
microk8s.stop
microk8s.start