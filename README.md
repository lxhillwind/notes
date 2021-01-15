------------------------------------------------------------------------------

# gitconfig

```gitconfig
[alias]

a = !git config --get-regexp alias. | sort
g = !git --git-dir ~/dotfiles/.git --work-tree ~

vim = !git -C ~/vimfiles/pack/git
vim-doc = !git vim submodule foreach vim --cmd 'sil! helpt doc | q'

vim-opt = !git -C ~/vimfiles/pack/git/opt
vim-start = !git -C ~/vimfiles/pack/git/start
```

------------------------------------------------------------------------------

# `_vimrc` on Windows

```vim
command! KtoggleShell call s:ToggleShell()
function! s:ToggleShell()
    if &shell =~ 'sh'
        let &shell = 'cmd.exe'
        let &shellcmdflag = '/s /c'
        let &shellquote = ''
    else
        let &shell = 'busybox sh'
        let &shellcmdflag = '-c'
        if has('nvim')
            let &shellquote = '"'
        endif
    endif
endfunction

" gui init
function! s:gui_init()
    set guioptions=
    set lines=32
    set columns=128

    if has('nvim')
        GuiTabline 0
    endif
endfunction

if !get(g:, 'vimrc#loaded')
    " so vimrc
    source ~/vimfiles/rc.vim

    " avoid /bin/sh as &shell; set busybox if possible; else set cmd.exe
    KtoggleShell
    if (!executable('busybox') && stridx(&sh, 'sh') >= 0)
                \ ||
                \ (executable('busybox') && stridx(&sh, 'sh') < 0)
        KtoggleShell
    endif

    if has('nvim')
        au UIEnter * call <SID>gui_init()
    elseif has('gui_running')
        call s:gui_init()
    endif

    " light theme
    set bg=light
endif
```

------------------------------------------------------------------------------

# gitconfig on Windows

```gitconfig
bb = !busybox
```

------------------------------------------------------------------------------

# END
