---
title: Expand a Proxmox Debian VM disk size
permalink: /expand-proxmox-debian-vm-disk-size
layout: post
date: 2026-05-09
category: post
---

In Proxmox under the VM's Hardware tab select the hard disk, then select Disk Action -> Resize, then restart the VM.

That increases the raw disk size, but it then needs to be extended in Debian to be usable.

Open a terminal into the Debian VM and identify the disk using `df`:

![df output](/images/2026-05-09-expand-proxmox-debian-vm-disk-size/df-output.png)

So in this example the disk is `sda` and the partition is `/dev/sda1`.

If this is the primary (boot) disk it might have an MBR and swap partition which will stop being able to just increase `/dev/sda1`. Check it out first:

```sh
sudo fdisk -l /dev/sda
```

There's instructions at the end for removing the extended partitions and setting up a file-based swap.

If there are no other partitions on `sda` you should just be able to just resize the partition.

```sh
sudo fdisk /dev/sda
d # This should delete partition 1
n
p
1
2048
<ENTER> # to select the default last sector
# you'll probably be prompted about the ext4 signature, DON'T delete it
n
w

# Now reboot again
sudo shutdown -r now
# ...

# Resize the filesystem
sudo resize2fs /dev/sda1

# Verify
$ df
Filesystem     1K-blocks     Used Available Use% Mounted on
udev            16414908        0  16414908   0% /dev
tmpfs            3287256    10244   3277012   1% /run
/dev/sda1      131922644 65856272  60366080  53% /
tmpfs           16436280        0  16436280   0% /dev/shm
tmpfs               5120        0      5120   0% /run/lock
tmpfs               1024        0      1024   0% /run/credentials/systemd-journald.service
/dev/sdb1      491133848  8579328 457532824   2% /mnt/storage
tmpfs           16436280        0  16436280   0% /tmp
tmpfs               1024        0      1024   0% /run/credentials/getty@tty1.service
tmpfs            3287256        8   3287248   1% /run/user/1000
```

## Removing extended partitions and adding swap

```sh
swapoff -a
fdisk /dev/sda
```

Delete blocking partitions
```
# Delete the MBR partition
d
2
# Delete the swap partition
d
5
# Delete and recreate sda1
d
1
n
p
1
2048
<ENTER> # use full disk
# If prompted about ext4 signature, don't delete it
n
# Write
w
```

Reboot:

```sh
reboot
```

Now you can expand the file system, **following the instructions above**. Then come back here to create the swap file:

```sh
fallocate -k 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

Make it persistent:

```sh
nano /etc/fstab
# add this:
/swapfile none swap sw 0 0
# and save and exit

# Verify
swapon --show
free -h
```



