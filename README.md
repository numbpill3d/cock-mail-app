# Cock-mail App

Cock-mail App packages Cock-mail 0.5.1 so it behaves like a normal Linux
desktop application on Arch-based systems.

After installation, you get a `Cock-mail` icon in your application launcher.
Clicking it starts the local Docker Compose services needed by Cock-mail and
opens the webmail UI in your browser.

This does not turn Cock-mail into an Electron app or a native mail client. It
keeps Cock-mail's original architecture:

- the UI is the upstream client-side Cock-mail web app
- IMAP and SMTP are bridged through local WebSocket services
- Docker Compose runs nginx and websockify in the background
- your browser opens `http://127.0.0.1:18142/`

The result is the practical part people expect from an app: a menu icon, one
click launch, and no need to manually `cd` into a folder and run Docker
commands.

## What It Installs

- `/opt/cock-mail-app/cock-mail` - bundled Cock-mail 0.5.1 source
- `/usr/bin/cock-mail-app-launch` - launcher script
- `/usr/share/applications/cock-mail-app.desktop` - app menu entry
- `/usr/share/icons/hicolor/256x256/apps/cock-mail-app.png` - app icon
- `/usr/share/doc/cock-mail-app` - documentation

At runtime, the launcher creates and manages this per-user working directory:

```text
~/.local/state/cock-mail-app
```

That directory holds the Docker Compose project, downloaded Alpine base files,
and generated runtime state. It is intentionally per-user instead of being
written into `/opt`.

## Defaults

The packaged launcher is configured for Cock.li:

```text
IMAP: mail.cock.li:993
SMTP: mail.cock.li:465
Local URL: http://127.0.0.1:18142/
```

The local nginx ports are bound to localhost:

```text
127.0.0.1:18142 -> container port 8142
127.0.0.1:18143 -> container port 8143
```

## Requirements

Install-time dependencies are handled by the package:

- `docker`
- `docker-compose`
- `xdg-utils`
- `bash`
- `coreutils`
- `curl`
- `gnupg`

You still need Docker running, and your user must be allowed to use Docker.
On a typical Arch install:

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Log out and back in after changing Docker group membership.

## Install From AUR-style Sources

Clone this repo and build it like any Arch package:

```bash
git clone https://github.com/numbpill3d/cock-mail-app.git
cd cock-mail-app
makepkg -si
```

Once installed, launch `Cock-mail` from your application menu.

You can also start it from a terminal:

```bash
cock-mail-app-launch
```

## Stop The Background Services

The app keeps Docker containers running after the browser opens, because the
webmail page needs the WebSocket bridges while you use it.

To stop them:

```bash
cd ~/.local/state/cock-mail-app
docker compose down
```

To check status:

```bash
cd ~/.local/state/cock-mail-app
docker compose ps
```

## Reconfigure Mail Servers

The launcher writes a `docker-compose.override.yml` into the runtime state
directory every time it starts. The packaged default targets Cock.li.

For a custom build, edit `scripts/cock-mail-app-launch` before packaging and
change the IMAP/SMTP target lines:

```yaml
websockify_imap:
  command: ["websockify", "--ssl-target", "-v", "8143", "mail.example.com:993"]
websockify_smtp:
  command: ["websockify", "--ssl-target", "-v", "8025", "mail.example.com:465"]
```

Cock-mail does not support STARTTLS here; use TLS-wrapped IMAP/SMTP ports such
as `993` and `465`.

## AUR Notes

This package is intentionally named `cock-mail-app` instead of `cock-mail`
because it is a desktop-app wrapper around the upstream Docker distribution.

The package installs files to standard Arch locations:

- `/opt` for the bundled self-contained Cock-mail distribution
- `/usr/bin` for the launcher
- `/usr/share/applications` for the desktop entry
- `/usr/share/icons` for the app icon
- `/usr/share/doc` and `/usr/share/licenses` for documentation and licenses

The wrapper license is `0BSD`. Cock-mail's upstream license notice is treated
as `LicenseRef-cock-mail` and is preserved in `LICENSE.upstream` and the
bundled upstream files.

## Source

Bundled upstream version:

```text
Cock-mail 0.5.1 beta
Original archive SHA-256:
a61f8784081f61e1056e4775159ac415e4db8df6a27d33916344f616107098d1
```

Cock-mail project page:

```text
https://mail.cock.li/cock-mail/
```
