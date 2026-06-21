---
title: Vibing on the couch with SSH
permalink: /vibing-on-the-couch-with-ssh
layout: post
date: 2026-06-21
category: post
---

My couch is a big part of my life. From British crime dramas to.. other British crime dramas, my evenings are generally spent in the lounge room. But sometimes inspiration strikes at times when I don't feel like rushing off to the office.

I've been leaning on Claude Code quite heavily for a number of personal side projects like [Sid](https://sid.tanbydynamics.co/) and [Logo2OpenSCAD](https://logo2openscad.becdetat.com/). I'm not quite there with using Claude Code on my phone developing new features. I want to have control over commits and testing, and occasionally hand-tweaking code, plus pushing up tags for releasing my projects. I also want to work on and maintain my homelab servers when I'm otherwise relaxing, where I self-host different services; this mainly involves pulling and deploying new Docker images.

I like command line workflows, although I generally use VS Code for coding and orchestrating Claude and Copilot, and I use [Fork](https://git-fork.com/) as a Git client for staging commits (highly recommended). I wanted to be able to migrate most of that workflow to the couch-based lifestyle.

## Hardware and validation

I have an iPad Air that I am mainly using for reading crochet patterns (I also like to crochet while I'm watching British crime dramas) so I wanted to use that rather than pulling out a full laptop.

My first step was to validate the idea. I found an SSH client called [Termius](https://termius.com/index.html). This has a subscription model, but the free tier seems ok for me as I don't need to share credentials across different platforms, and Termius on the free tier remembers SSH usernames and passwords.

I used Termius to sign into my main homelab server, which is a Debian server (a VM on my main bare metal physical server that runs ProxMox). I tested how it feels to navigate around and do simple things like using Nano to edit files and to trigger Docker container updates.

Using a SSH terminal on a bare iPad was pretty clunky, but it generally worked ok, so I picked up a [Logitech keyboard case](https://www.amazon.com.au/dp/B0D4LXJNF5). It must have been on sale at the time because I paid a lot less than the current price of $222 AUD - if it was that much I might have reconsidered my decisions... The keyboard is quite nice apart from not having a dedicated `escape` button - I've remapped the `Globe` button to `escape`. I can also fold the keyboard under the iPad when I'm not using it, so it fits nicely on the arm of my lounge when I'm crocheting (while watching British crime dramas). This was a requirement that ruled out using an old laptop or buying something like a MacBook Neo.

## Software configuration

I wanted a dedicated local development machine. I didn't want to do development on my main homelab server as it hosts "production" services that I use regularly, either locally (or via Tailscale) like [Jellyfin](https://jellyfin.org/), [Gitea](https://about.gitea.com/), or [Kimai](https://www.kimai.org/en/) (great for timesheets), or published to the web via Cloudflare application routes. So to keep things separate I spun up a new Debian VM in ProxMox. I called it `seagull` because I name my machines after birds.

Here's the software I set up:
1. [Docker](https://becdetat.com/install-docker-on-debian) for running development environments
2. Python - Claude Code loves writing arbitrary Python scripts while doing its work
3. Claude Code CLI - `curl -fsSL https://claude.ai/install.sh | bash`
4. `uv` and [Serena](https://oraios.github.io/serena/01-about/000_intro.html) - Serena helps Claude Code remember context in a codebase:
```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install -p 3.13 serena-agent
serena init
```
5. [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian) - I don't actually use GitHub CLI but this sets up Git with GitHub credentials very smoothly
6. [Tailscale](https://tailscale.com/download/linux)

I also installed GitUI and Fresh.

[GitUI](https://github.com/gitui-org/gitui) is a TUI interface for Git. It isn't perfect, but it lets me work very similarly to how I use Fork for staging commits, including staging parts of files. There isn't a simple method of installation using Debian, but there's an install script available in a GH issue [here](https://github.com/gitui-org/gitui/issues/1018#issuecomment-2994005269).

![GitUI](/images/2026-06-21-vibing-on-the-couch-with-ssh/gitui.png)

[Fresh](https://getfresh.dev/) is an IDE/text editor that has a similar feel to VS Code but as a TUI application. Again not perfect - [LSP](https://getfresh.dev/docs/features/lsp) took extra configuration for TypeScript. I'm used to VS Code handing everything to me on a platter though.

![Fresh](/images/2026-06-21-vibing-on-the-couch-with-ssh/fresh.png)

## My workflow

I've cloned my repositories to `~/development`.

I open up three SSH sessions in the repository directory.

The first is for Claude Code - I just run `claude` from the repo directory.

The second is a working session. I use it for running tests, making edits using Fresh, and staging commits in GitUI.

In the third session I run the application - something like `npm run dev` - so I can test and validate the changes that Claude has made. For a simple application like Sid this shows several URLs for the frontend. I can just open the link containing `seagull`'s IP address in Safari on the iPad, and do a three-finger swipe to switch between Termius and Safari.

## The road warrior dream

This isn't perfect; there's plenty of jankiness with this setup, but it gives me a full environment I can use to build and run basically anything I want, with a full local server running the tools I need. Tailscale lets me work from anywhere while tethered to a phone, without needing to drag along a laptop.








