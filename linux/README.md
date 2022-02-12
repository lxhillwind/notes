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
