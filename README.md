# Deploy and Host code-server on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/code?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=code-server)

code-server runs VS Code in your browser: the editor, extensions, the integrated terminal and Git, on a server you can reach from any device. This template runs it on Railway behind a password, with Node.js, Python and build tools ready in the terminal, and a volume that keeps your projects, settings and extensions across redeploys.

This is a community template, not made or supported by Coder or Microsoft.

## About Hosting code-server

code-server needs a long-running server with storage that survives restarts, a password in front of it, and a public HTTPS address that passes WebSockets. Railway gives it all three. This template:

- opens on a password generated at deploy time (the `PASSWORD` variable)
- keeps `/home/coder` on a volume: your projects in `~/workspace`, extensions, settings, shell history and anything you install with `npm -g --prefix ~/.local` or `pip install --user`
- prepares the volume for the `coder` user, so the editor and terminal never hit permission errors
- adds Node.js LTS with npm and npx, Python 3 with pip and venv, gcc and make, ripgrep, jq, tmux and zip to the official image

**Open it:** visit the service's domain and enter the `PASSWORD` from the service's Variables tab.

## Common Use Cases

- A full VS Code from a tablet, a Chromebook or a borrowed computer
- A dev box next to your Railway databases, reaching them over the private network
- Editing and testing a project when your own machine is too slow or not with you

## Dependencies for code-server Hosting

- A Railway account. The editor itself needs no outside services.

### Deployment Dependencies

- [code-server](https://github.com/coder/code-server)
- [code-server docs](https://coder.com/docs/code-server)
- [Template source](https://github.com/two-workspaces/code-server)

### Implementation Details

- **Tested on Railway:** PENDING
- **Extensions** come from [Open VSX](https://open-vsx.org), the open marketplace code-server uses. Most popular extensions are there; a few Microsoft-only ones (Remote, Live Share, the C# Dev Kit) are not.
- **What persists:** everything under `/home/coder`. Packages installed with `sudo apt-get install` are gone after a redeploy, since they live outside the volume. Put setup commands in an executable script in `~/entrypoint.d` to rerun them on every start.
- **Security:** the password protects a terminal with sudo. Keep it strong, and change it by editing `PASSWORD` (the service redeploys).
- **Memory:** PENDING
- **Updates:** a new code-server version comes with an update of this template; the in-app update check is off.
- **Image:** `ghcr.io/two-workspaces/code-server`, built from this repository's Dockerfile on `codercom/code-server:4.145.2`.

## Why Deploy code-server on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying code-server on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
