---
title: Docker container cannot reach internet with Tailscale
permalink: /docker-container-cannot-reach-internet-tailscale
layout: post
date: 2026-05-09
category: post
---

One of my Docker containers (a [FreshRSS](https://freshrss.org/index.html) instance) wasn't able to connect to the internet after setting it up on a new server. This can be because of Tailscale's DNS server being stripped by Docker, leaving it with no external nameservers. A fix is to explicitly add Cloudflare and Google nameservers to the container definition in `docker-compose.yml`:

```yaml
dns:
  - 1.1.1.1 # Cloudflare
  - 8.8.8.8 # Google
```

Restart the container and test it:

```sh
docker compose up -d
docker exec <container-name> curl google.com
```

You should see a redirect from google.com to `https://www.google.com` if the DNS resolution is working. Your container can now access the internet.