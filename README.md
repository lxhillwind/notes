------------------------------------------------------------------------------

# gitconfig
<https://gitee.com/lxhillwind/dotfiles/blob/master/.config/git/config>

------------------------------------------------------------------------------

# vm
Choose based on host OS.

Just use qemu on Linux. Guest OS (Windows / Linux) in VirtualBox (Linux host)
seems to have font rendering issue (scale mode?). GL support (Linux guest on
Linux host) is much better than on VirtualBox.

Use VirtualBox on macos. qemu network (Windows guest) seems buggy. Display
(cocoa) is also not well supported.

------------------------------------------------------------------------------

# vimrc

```vim
" :Rgbuffer {...} {{{
" requires vim plugin: sh.vim (:Sh), jump.vim (<Plug>(jump_to_file))
command! -nargs=+ Rgbuffer call s:rg(<q-args>)

function! s:jumpback(buf) abort
  let buffers = tabpagebuflist()
  let idx = index(buffers, a:buf)
  if idx >= 0
    execute 'normal' idx+1 "\<Plug>(jump_to_file)"
  else
    echoerr 'buffer not found!'
  endif
endfunction

function! s:rg(arg) abort
  let buf = bufnr()
  let l:result = execute('%Sh rg --column ' . a:arg)
  bel 7sp +enew | setl buftype=nofile
  put =l:result
  norm gg"_dd
  execute printf("nnoremap <buffer> <CR> <cmd>call <SID>jumpback(%s)<CR>", buf)
  syn match String '\v^[0-9]+'
endfunction
" }}}
```

## clipboard via osc52

Access system clipboard in session via ssh, serial console, etc.

```vim
Plug 'https://github.com/fcpg/vim-osc52'
silent! let g:plugs['vim-osc52'].commit = '551f20e62e68684a5b745ae08b0c4236d86e4c2b'

nnoremap <Leader>y :Oscyank<CR>
nnoremap <Leader>p :echoerr 'system clipboard is not available!'<CR>
```

------------------------------------------------------------------------------

# zshrc

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

------------------------------------------------------------------------------

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

------------------------------------------------------------------------------

# END

<!-- vim: tw=78 fdm=marker -->
