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

`EDITOR=micro`


