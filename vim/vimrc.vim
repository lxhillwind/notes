" vim:fdm=marker

vim9script

# pkgs {{{1
runtime rc/pkgs.vim

g:loaded_fzf = 1

Pack 'pyvim',#{skip: 1}
g:pyvim_rc = expand('~/vimfiles/config/pyvim.py')

Pack 'https://github.com/ziglang/zig.vim'

Pack 'https://github.com/masukomi/vim-markdown-folding'
g:markdown_fold_style = 'nested'
g:markdown_fold_override_foldtext = 0

syntax on


# ft {{{1
augroup vimrc_ft
  au!
  au BufRead */qutebrowser/qutebrowser.service setl ft=systemd
augroup END

# misc {{{1
if has('gui_running')
  set gfn=Hack\ 12
  set bg=light
endif

command! -nargs=+ Man Terminal zsh -ic 'man <q-args>'

# :Rgbuffer {...} {{{2
command! -nargs=+ Rgbuffer call s:rg(<q-args>)

legacy function! s:jumpback(buf) abort
  let buffers = tabpagebuflist()
  let idx = index(buffers, a:buf)
  if idx >= 0
    execute 'normal' idx+1 "\<Plug>(jump_to_file)"
  else
    echoerr 'buffer not found!'
  endif
endfunction

legacy function! s:rg(arg) abort
  let buf = bufnr()
  let l:result = execute('%Sh rg -I --column ' .. a:arg)
  bel 7sp +enew | setl buftype=nofile
  put =l:result
  norm gg"_dd
  execute printf("nnoremap <buffer> <CR> <cmd>call <SID>jumpback(%s)<CR>", buf)
  syn match String '\v^[0-9]+'
endfunction

# exe {{{2
au BufReadCmd *.exe,*.dll call s:read_bin(expand('<amatch>'))
au BufWriteCmd *.exe,*.dll call s:write_bin(expand('<amatch>'))

# avoid using busybox xxd.
legacy let s:xxd = exists($VIM . '/bin/xxd') ? '"$VIM"/bin/xxd' : 'xxd'

legacy function! s:read_bin(name) abort
  execute printf('r !%s %s', s:xxd, shellescape(a:name))
  normal gg"_dd
endfunction

legacy function! s:write_bin(name) abort
  if has('win32') && !has('nvim')
    " returncode check is ignored.
    job_start('xxd -r', #{in_io: 'buffer', in_buf: bufnr(), out_io: 'file', out_name: a:name})
  else
    execute printf('%w !%s -r > %s', s:xxd, shellescape(a:name))
    if !empty(v:shell_error)
      return
    endif
  endif
  setl nomodified
  redrawstatus | echon 'written.'
endfunction
