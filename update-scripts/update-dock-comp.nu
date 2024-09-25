#!/usr/bin/env nu

# sudo systemctl start docker

# docker compatibility for podman
# podman machine start
systemctl --user restart podman.socket
sudo ln -fs {$XDG_RUNTIME_DIR}/podman/podman.sock /var/run/docker.sock
