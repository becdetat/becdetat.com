---
title: Mount an NFS share
permalink: /mount-an-nfs-share
layout: post
date: 2026-05-09
category: post
---

First install the NFS client utilities:

```sh
sudo apt update
sudo apt install nfs-common
```

Verify the NFS server export:

```sh
sudo showmount -e <server name or IP>
# Output:
Export list for hornbill:
/export          192.168.0.0/24
/export/backup   192.168.0.0/24
/export/littleun 192.168.0.0/24
/export/biggun   192.168.0.0/24
```

Make the mount point and manually mount the share. If you reboot after this point the mount will be lost, so keep going.

```sh
sudo mkdir -p /mnt/backup
sudo mount -t nfs <server name or IP>:/export/backup /mnt/backup
# Verify
df -h
ls /mnt/backup
```

Persist via `/etc/fstab`:

```sh
sudo nano /etc/fstab
# Add
<server name or IP>:/export/backup /mnt/backup nfs rw,hard,intr,_netdev,noatime 0 0
# Then test
sudo mount -a
```



