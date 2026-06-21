---
title: Set up sudo and add a user to sudo group
permalink: /set-up-sudu-and-add-user-to-sudo-group
layout: post
date: 2026-05-09
category: post
---

Debian doesn't have `sudo` by default so it will need to be installed manually.

Open a `su` session, install `sudo`, and add the required user to the `sudo` group:

```sh
su -
apt install sudo
usermod -aG sudo <username>
exit
```

Now exit the current session and restart it to have the group change applied. You should be able to use `sudo` now.
