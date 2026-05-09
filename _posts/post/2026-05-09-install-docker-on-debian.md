---
title: Install Docker on Debian
permalink: /install-docker-on-debian
layout: post
date: 2026-05-09
category: post
---

[Docker's install instructions for Debian](https://docs.docker.com/engine/install/debian/).

Do this as a user account, not `root`, but all commands are using `sudo`.

```sh
# Uninstall conflicting packages
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install the Docker packages
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test the install
sudo systemctl status docker
sudo docker run hello-world
```

You can add your user to the `docker` group so you don't have to use `sudo` to manage docker:

```sh
sudo usermod -aG docker bec
# Reload the shell to apply the permissions
```