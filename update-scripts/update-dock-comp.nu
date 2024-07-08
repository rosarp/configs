#!/usr/bin/env nu

# docker compatibility for podman
systemctl --user restart podman.socket
sudo ln -fs /run/user/1000/podman/podman.sock /var/run/docker.sock
