---
title: Restore a Zerobyte backup
permalink: /restore-a-zerobyte-backup
layout: post
date: 2026-05-09
category: post
---

Create a Zerobyte container. Here's an example `docker-compose.yml`:

```yml
services:
  zerobyte:
    image: ghcr.io/nicotsx/zerobyte:latest
    container_name: zerobyte
    restart: unless-stopped
    ports:
      - 3100:4096
    environment:
      - TZ=UTC
      - BASE_URL=http://td-app1:3100
      - APP_SECRET=28274b2fd22592672a26f25aa60977466767c93fab4c95dfcb85c3c8916b3f87
    volumes:
      - ./data:/var/lib/zerobyte
      - /mnt/backup:/mnt/backup
      - /home/bec/restore:/mnt/restore
```

Open <http://your-server:3100> and create an admin user.

Create a repository for the backup to restore:

![Zeroconf screenshot showing the create repository information](/images/2026-05-09-restore-a-zerobyte-backup/create-zerobyte-repository.png)

The repository password is from the .pass file created on the source backup zerobyte server.

Go to "Snapshots", pick the snapshot to restore, and click "Restore".

Select the location in `/mnt` to restore to.

