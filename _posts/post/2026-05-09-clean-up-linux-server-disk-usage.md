---
title: Clean up Linux server disk usage
permalink: /clean-up-linux-server-disk-usage
layout: post
date: 2026-05-09
category: post
---

Run this to show usage starting from `/`:

```sh
du -cha --max-depth=1 / | grep -E "M|G"
# or
du -ahx / | sort -rh | head -n 30
```

Then to go down a level, say to `/var`:

```sh
du -cha --max-depth=1 /var | grep -E "M|G"
```

Or you can get journalctl to report on how much space it's using:

```sh
journalctl --disk-usage
# then
journalctl --vacuum-size=200M
```

It should be safe to delete files in `/var/logs` but you should then investigate what is spamming the logs.

```sh
truncate -s 0 /var/log/*.log
```

If this makes `/var/log` smaller but `df` still shows 100% you might have orphaned inodes, which is bad. You need to run fsck on reboot:

```sh
touch /forcefsck
reboot
```

