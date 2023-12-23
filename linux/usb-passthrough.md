% qemu usb passthrough
%
% 2023-04-07

# brief

reference:

<https://wiki.archlinux.org/title/Udev>

<https://unix.stackexchange.com/questions/250938/qemu-usb-passthrough-windows-guest>

- get vendorid and productid by inspecting `lsusb` output.

    replace xxxx / yyyy with real id.

- add permission for wheel group (udev)

add file in /etc/udev/rules.d/, e.g. `90-betop.rules`.

```
ATTRS{idVendor}=="xxxx", ATTRS{idProduct}=="yyyy", GROUP="wheel"
```

- reload rules manually (optional?)

```sh
# root
udevadm control --reload
```

- qemu cmdline option

```sh
... -usb -device usb-host,vendorid=0x{xxxx},productid=0x{yyyy} ...
```

# fedora

package `qemu-device-usb-host` is required; otherwise device type `usb-host`
will not be recognized.

# bubblewrap

<!--
If qemu is wrapped with bubblewrap (`--dev /dev`)...
-->

workaround with qemu-img (a fake usb img) and dd.
