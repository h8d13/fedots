# Fedots

Starts from https://fedoraproject.org/misc/ "Fedora Everything X"

**Do not tick any desktop or addons.** Just create user and select disk + keyboard stuff.
> I like to start at small point and modify each small part that I add.

## System

### Pkg-manager

contents of `/etc/dnf/dnf.conf`
```
[main]
max_parallel_downloads=10
metadata_expire=1d
install_weak_deps=False
```

### Pkg-config

```
dnf install git sway foot micro
```

Set it as default:

Contents of `/etc/environment`

```
EDITOR=micro
TERMINAL=foot
```

### Sound

```
dnf install pipewire wireplumber pipewire-pulseaudio
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
```

## Eye-candy

### Theme and status bar

Everything uses micro's `atom-dark` palette.

- `foot/foot.ini` → `~/.config/foot/foot.ini` terminal
- `sway/config` → `~/.config/sway/config` (vendored from [upstream config.in](https://github.com/swaywm/sway/blob/master/config.in), colors added)
- `sway/status.sh` → `~/.config/sway/status.sh` (bar text: battery, cpu, memory, load, clock)

### Preview

<img width="1280" height="800" alt="Screenshot_20261013_175456" src="https://github.com/user-attachments/assets/b074343a-bf21-4cc6-9e63-7c0a187c6117" />
