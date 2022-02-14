# installation note

Un-plug rtl8192 network controller before installation;
otherwise kernel will load buggy `rtl8192cu` module, which hang the system
(maybe for several minutes).

(The working module is `rtl8xxxu`.)

Before plug it (after system installation), add rtl8192cu module to blacklist
first.

```
# add to file under /etc/modprobe.d/, e.g., /etc/modprobe.d/rtl8192cu.conf

blacklist rtl8192cu
```

optional: `blacklist pcspkr` (no beep).

# run Arch Linux in sandbox (bubblewrap)

## install

- dir: root.x86_64; new-root;
- install fakechroot in rootfs first (just ignore the error); (use `--assume=perl` to save time)
- run `pacman` with `fakechroot`, so `pacman` will not show error for chroot
  again.

```sh
bwrap --uid 0 --gid 0 --bind root.x86_64 / --tmpfs /tmp --ro-bind /etc/resolv.conf /etc/resolv.conf --bind new-root /mnt/ --dev /dev --proc /proc --unshare-all --share-net --clearenv --setenv TERM "$TERM" --setenv USER root /bin/bash
```

## run (root)

- dir: ~/.sandbox/archlinux

```sh
bwrap --uid 0 --gid 0 --bind ~/.sandbox/archlinux / --tmpfs /tmp --ro-bind /etc/resolv.conf /etc/resolv.conf --dev /dev --proc /proc --unshare-all --share-net --clearenv --setenv TERM "$TERM" --setenv USER root ---new-session -die-with-parent /bin/bash
```

## run (non-root)

- dir: ~/.sandbox/archlinux
- dir: ~/.sandbox/archlinux/"$HOME"

```sh
bwrap --ro-bind ~/.sandbox/archlinux / --bind ~/.sandbox/archlinux/"$HOME" "$HOME" --tmpfs /tmp --ro-bind /etc/resolv.conf /etc/resolv.conf --dev /dev --proc /proc --unshare-all --share-net --clearenv --setenv TERM "$TERM" --setenv USER "$USER" --setenv HOME "$HOME" --setenv PATH "$HOME/bin:/bin:/usr/local/bin" ---new-session -die-with-parent /bin/bash
```
