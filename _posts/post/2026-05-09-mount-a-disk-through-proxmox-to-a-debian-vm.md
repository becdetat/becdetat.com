---
title: Mount a disk through Proxmox to a Debian VM
permalink: /mount-a-disk-through-proxmox-to-a-debian-vm
layout: post
date: 2026-05-09
category: post
---

## Pass through the disk from Proxmox

On the Proxmox server, list the disk devices:

```sh
ls -l /dev/disk/by-id/
```

Identify the ID of the disk. It will be something like `ata-ST3000DM003-1F216N_S300YXNZ`.

Identify the VM ID:

```sh
qm list
```

Attach the disk:

```sh
qm set 101 -scsi /dev/disk/by-id/ata-ST3000DM003-1F216N_S300YXNZ
```

## Mount the disk in the VM

On the Debian VM, find the UUID:

```sh
sudo blkid

# it will be something like:
# /dev/sdb1: UUID="d41c56b2-6a44-4f12-9123-def987654321" TYPE="ext4"
```

Create the mount directory:

```sh
sudo mkdir -p /mnt/storage
```

Edit fstab:

```sh
sudo nano /etc/fstab
```

Add:

```sh
UUID=d41c56b2-6a44-4f12-9123-def987654321 /mnt/storage ext4 defaults 0 2
```

If you're trying to mount a Btrfs volume you might need to install the `btrfs-progs` package:

```sh
sudo apt install btrfs-progs
```

Apply:

```sh
sudo mount -a
```

Set permissions (optional):

```sh
sudo chown -R yourusername:yourusername /mnt/storage
```