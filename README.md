# link
- repo: <https://gitee.com/lxhillwind/lxhillwind> / <https://github.com/lxhillwind/lxhillwind.github.io>
- [linux/README.md](linux/README.md)
- [windows/README.md](windows/README.md)
- [bubblewrap wrapper script collections](sandbox-script/README.md)
- [vimium](vimium/vimium-options.json)
- vscode
    - [vscode setting](vscode/vscode-settings.json)
    - [vscode keybindings](vscode/vscode-keybindings.json)
    - [vscode tasks](vscode/vscode-tasks.json)

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


## about `go-!` option
It makes `:!{cmd}` in gvim on win32 run cmd in embeded window, but stderr (?)
is discarded.

So do not use it.

# zsh
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

# ssh

## local port forwarding

`-D` flag.

```sh
ssh -D 9050 -N "{host}"
```

# kde

## bind `Meta` (`Windows`) key

When setting shortcut key, press `Meta+F1`.

source: <https://unix.stackexchange.com/questions/519187/use-meta-super-windows-whatever-key-to-open-kde-plasmas-application-launcher-k>

# 20220826_113926 Zettelkasten for task tracking
#Zettelkasten #work

- add `#TODO` / `#DONE` as tag to track task status.
- Use vim's `:vimgrep` or `grep` shell command to filter on tag (with regex
  `^#` to filter lines define tag; exclude `#` in body).
- also add tag for keyword as category.
- bonus: output html, with `#DONE` / `#TODO` in html class; add button to hide
  / show them.
- use `<h1>` (html; in markdown it's `# xxx`) to record a task. no nested
  level required.

---
<https://zettelkasten.de/introduction/>

# 20220827_093944 botw IST bug
#botw #ist #game

---

# 20220827_144841 support wsl in gvim win32
#wsl #vim #gvim

- link ~/vimfiles, ~/.gitconfig, ~/.config/git/config to wsl home;
- copy ~/bin/dgit to wsl home, and modify it, set `--git-dir` / `--work-tree`
  to windows home.

Then `dgit` will work as expected.

cons:

- path; wsl path is not compatible with windows path, then shell cmd / script
  is not exchangeable.

---

# 20220827_154900 install fedora (actually any distro) in wsl (wsl1)
#wsl #docker #fedora

via wsl's `--import` option. It also supports wsl version 1!

fedora only: to get rootfs of fedora, go to
<https://mirrors.bfsu.edu.cn/fedora/releases/36/Container/x86_64/images/>,
download the image, and extract it; there is a `.tar` file in it, which
contains rootfs. (this should also works for other docker image generated via
`podman save {image} > xxx.tar`.

tip: after setting up new user, edit `/etc/wsl.conf` to set default user on
login.

---
<https://docs.microsoft.com/zh-cn/windows/wsl/use-custom-distro>

# 20220904_151229 vim mark files for later use (bookmark)
# 20220911_140549 vim open file in with xxd if it seems like a binary file
# 20220912_093801 git on windows: how to change file mode

```sh
git update-index --chmod=+x path/to/file.ext
# or make it not executable:
git update-index --chmod=-x path/to/file.ext
```

Git stores only one bit for file permissions so it’s not possible to change
CHMOD values to something else, such as 0750 in Windows.

# 20220918_152356 chicken scheme: cross compile (from linux x64 to windows i386)
#zig #scheme

## requirement
- chicken installation in host system; (easy: just install it with distro's
  package manager)
- chicken source code; (which is used to build win32 libchicken.a)
- zig; (ease C cross compilation)

## steps
- => libchicken.a: (once generated, then no need to rebuild it)

`make C_COMPILER=zig-cc-i386-windows-gnu PLATFORM=cross-linux-mingw LIBRARIAN='zig ar' CHICKEN=chicken libchicken.a`

- t.scm => t.c:

`csc -t t.scm`

- t.c => t.exe:
    - "chicken.h": -I include path should be replaced with actual path containing chicken.h
    - libchicken.a path should be replaced with actual path pointing to libchicken.a

`zig-cc-i386-windows-gnu -o t.exe t.c ~/repos/chicken-core/libchicken.a -lws2_32 -I ~/repos/chicken-core`

(c to exe in seperate step for easier inspection:)

    t.c => t.obj:

    `zig-cc-i386-windows-gnu t.c -c -I ~/repos/chicken-core`

    t.obj => t.exe:

    `zig-cc-i386-windows-gnu -o t.exe t.obj ~/repos/chicken-core/libchicken.a -lws2_32`

NOTE: zig-cc-i386-windows-gnu is a wrapper for `zig cc -target i386-windows-gnu`.
Some languages (like Nim / Golang) don't support space in C compiler name, so
I create the wrapper script to make them work.

## Windows XP compatibility?
To make generated exe work in Windows XP, before building `libchicken.a`,
function `GetTickCount64` in source code `runtime.c` should be replaced (or
comment out).

For genereted exe, byte patching is required (xxd, replace the first `0600` in
the 13th line of xxd output with `0500` (`0501`?)).

If more module is loaded into scheme code, then maybe more win32 function
would be loaded into final exe. For example, to compile csi.scm to csi.exe,
`GetFinalPathNameByHandle` will be loaded, which is not available in Windows
XP.
# 20220920_213506 less.exe: cross compile (from linux to windows i386)
#less #Windows_XP
patch for Makefile.wng:

```diff
26c26
< CC = gcc
---
> CC = zig-cc-i386-windows-gnu
39a40
> REGEX_PACKAGE = regcomp-local
63c64
< SHELL = cmd.exe
---
> SHELL = sh
76c77
< 	${CC} -c -I. ${CFLAGS} $<
---
> 	${CC} -c -I. ${CFLAGS} $< -o $*.o
104c105
< 	${CC} ${LDFLAGS} -o $@ ${OBJ} ${LIBS}
---
> 	${CC} ${LDFLAGS} -o $@.exe ${OBJ} ${LIBS}
107c108
< 	${CC} ${LDFLAGS} -o $@ lesskey.o lesskey_parse.o version.o xbuf.o
---
> 	${CC} ${LDFLAGS} -o $@.exe lesskey.o lesskey_parse.o version.o xbuf.o
110c111
< 	${CC} ${LDFLAGS} -o $@ lessecho.o version.o
---
> 	${CC} ${LDFLAGS} -o $@.exe lessecho.o version.o
113c114
< 	copy $< $@
---
> 	cp $< $@
```

Then run `make -f Makefile.wng less` to get `less.exe`.

To make `less.exe` run on Windows XP, modify binary, replace `\x06` with
`\x05` (see [[20220918_152356]]).
