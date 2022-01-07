# link
- [windows/README.md](windows/README.md)
- [vimrc.local](vim/vimrc.vim)

# gitconfig
<https://gitee.com/lxhillwind/dotfiles/blob/master/.config/git/config>

# vm
Choose based on host OS.

Just use qemu on Linux. Guest OS (Windows / Linux) in VirtualBox (Linux host)
seems to have font rendering issue (scale mode?). GL support (Linux guest on
Linux host) is much better than on VirtualBox.

Use VirtualBox on macos. qemu network (Windows guest) seems buggy. Display
(cocoa) is also not well supported.

# vim
## clipboard via osc52

Access system clipboard in session via ssh, serial console, etc.

```vim
Pack 'https://github.com/fcpg/vim-osc52', #{commit: '551f20e62e68684a5b745ae08b0c4236d86e4c2b'}

nnoremap <Leader>y :Oscyank<CR>
nnoremap <Leader>p :echoerr 'system clipboard is not available!'<CR>
```

## tasks.ini (see tasks.vim)
```ini
[conf-edit]
@key = ;
@glob = *

[conf-edit:tasks.ini]
* = tabe ~/vimfiles/rc/tasks.ini

[conf-edit:vimrc.local]
* = tabe ~/vimfiles/vimrc.local

[jump]
@key = j
@glob = *
* = call feedkeys("\<Plug>(jump_to_file)")
```

## about `go-!` option
It makes `:!{cmd}` in gvim on win32 run cmd in embeded window, but stderr (?)
is discarded.

So do not use it.

# zsh

```sh
# capture tmux output to put in vim (easy jump to file of rg / grep output)
# optional $1: start line from visible top; default: 1000
# requires vim plugin: sh.vim (:Terminal), jump.vim (<CR> in terminal buffer)
# shell: posix
sv()
{
    tmux capture -e -p -S -${1:-1000} -E $(tmux display -p "#{cursor_y}") | vim - -c 'set buftype=nofile noswapfile | %Terminal cat'
}
```

# qemu

## usb passthrough

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

# busybox-w32

build busybox-w32 using alpine linux (i386/alpine):

```sh
# build dependency
apk add musl-dev gcc make ncurses-dev mingw-w64-gcc

# then run `make mingw32_defconfig` and `make`, according to busybox-w32 README.md

# since perl is not installed, doc generation will fail;
# but $? should be 0 (err in doc generation is ignored).
```

# awk

## portable shebang

### cmd in `//`

NOTE:

- with pipe: verbose if slash (`/`) is in cmd;

with pipe:

```awk
#!/bin/sh
/ 2>\/dev\/null; exec sh -ec '{cmd} | awk -f "$0"' "$0" / {}

# ...
```

without pipe:

```awk
#!/bin/sh
/ 2>\/dev\/null; exec awk -f "$0"; / {}

# ...
```

### cmd in `{}`

NOTE:

- with pipe: warning message in gawk (about escape sequence);
- variable `false` should be undefined;

with pipe:

```awk
#!/bin/sh
false {
    "exec" "sh" "-ec" "cmd | awk -f \"\$0\"" "$0"
}

# ...
```

without pipe:

```awk
#!/bin/sh
false {
    "exec" "awk" "-f" "$0"
}

# ...
```

### `awk program`

NOTE:

- may exceed argument length limit for exec;
- with pipe: syntax highlight is bad;

with pipe:

```awk
#!/bin/sh
exec sh -c '{cmd} | awk "$0"' "$(awk 'NR > 2' "$0")"

# ...
```

without pipe:

```awk
#!/bin/sh
exec awk "$(awk 'NR > 2' "$0")"

# ...
```

# END
