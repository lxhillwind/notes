------------------------------------------------------------------------------

# gitconfig
<https://gitee.com/lxhillwind/dotfiles/blob/master/.gitconfig>

------------------------------------------------------------------------------

# vm
Choose based on host OS.

Just use qemu on Linux. Guest OS (Windows / Linux) in VirtualBox (Linux host)
seems to have font rendering issue (scale mode?). GL support (Linux guest on
Linux host) is much better than on VirtualBox.

Use VirtualBox on macos. qemu network (Windows guest) seems buggy. Display
(cocoa) is also not well supported.

------------------------------------------------------------------------------

# vim random config

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
  execute 'KvimRun' '%Sh rg --column' a:arg
  execute printf("nnoremap <buffer> <CR> <cmd>call <SID>jumpback(%s)<CR>", buf)
  syn match String '\v^[0-9]+'
endfunction
" }}}
```

------------------------------------------------------------------------------

# END

<!-- vim: tw=78 -->
