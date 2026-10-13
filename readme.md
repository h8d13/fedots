# Fedots

Starts from https://fedoraproject.org/misc/ "Fedora Everything X"

**Do not tick any desktop or addons.** Just create user and select disk + keyboard stuff.
> I like to start at small point and modify each small part that I add.

## Pkg-manager

contents of `/etc/dnf/dnf.conf`
```
[main]
max_parallel_downloads=10
metadata_expire=1d
install_weak_deps=False
```

## Pkg-config

```dnf install git sway foot micro```

Set it as default: 

Contents of `/etc/environment`

```
EDITOR=micro
```



## Theme

Everything uses micro's `atom-dark` palette.

- `foot/foot.ini` → `~/.config/foot/foot.ini`
- `sway/theme` → `~/.config/sway/theme`

In `~/.config/sway/config` (copy from `/etc/sway/config` first), add `include ~/.config/sway/theme` near the top, then give the bar block matching colors:

```
bar {
    position top
    status_command while date +'%Y-%m-%d %H:%M'; do sleep 30; done

    colors {
        background $bg
        statusline $fg
        separator  $dim
        #                  border  bg      text
        focused_workspace  $blue   $blue   $bg
        active_workspace   $bg-alt $bg-alt $fg
        inactive_workspace $bg     $bg     $dim
        urgent_workspace   $red    $red    $bg
    }
}
```
