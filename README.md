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

------------------------------------------------------------------------------

# zshrc

```sh
# capture tmux output to put in vim (easy jump to file of rg / grep output)
# optional $1: start line from visible top; default: 1000
# requires vim plugin: sh.vim (:Terminal), jump.vim (<CR> in terminal buffer)
sv()
{
    tmux capture -e -p -S -${1-:1000} -E $(tmux display -p "#{cursor_y}") | vim - -c 'set buftype=nofile noswapfile | %Terminal cat'
}
```

------------------------------------------------------------------------------

# END

<!-- vim: tw=78 fdm=marker -->
