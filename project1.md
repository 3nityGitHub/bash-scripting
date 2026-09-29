# Project1 — Linux VM Investigation

VM created with UTM on Apple Silicon Mac.
Note: Linux Mint has no native Apple Silicon (ARM) image, so I used
Ubuntu Server 26.04 LTS — the same Debian/apt family as Mint — and
documented the substitution. The investigation goal (identify distro,
package manager, editor, shell) is identical.

## Findings
- Distribution: Ubuntu 26.04.1 LTS "Resolute Raccoon"
- Based on: Debian (ID_LIKE=debian) — same family as Linux Mint
- Package manager: apt / apt-get (located at /usr/bin/). No yum (that's Red Hat family).
- CLI editors installed: nano, vim
- Shell: /bin/bash
- Software manager (GUI): not present on Server edition; Ubuntu Desktop/Mint use "Software Manager" / "Ubuntu Software"

## How I investigated
- `cat /etc/os-release` — distribution and version
- `which apt apt-get yum` — which package managers exist
- `which nano vim` — which editors are installed
- `echo $SHELL` — the configured shell
