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

# neovim on Windows

## setup

```console
~/apps $ ls -F . bin home
.:
MinGit/      Neovim/      bin/         home/        nvim-qt.lnk

bin:
less.exe*

home:
bin/      dotfiles/ info/     lib/      vimfiles/
```

## vimrc (Neovim/share/nvim/sysinit.vim)

```vim
command! KtoggleShell call s:ToggleShell()
function! s:ToggleShell()
    if &shell =~ 'sh'
        let &shell = 'cmd.exe'
        let &shellcmdflag = '/s /c'
        let &shellquote = ''
    else
        let &shell = 'git bb sh'
        let &shellcmdflag = '-c'
        let &shellquote = '"'
    endif
endfunction

if !get(g:, 'vimrc#loaded')
    " set env: vimrc; bin path; change home
    let $MYVIMRC = expand('<sfile>')
    let s:root = expand('<sfile>:p:h:h:h:h')
    if !executable('git')
        let $PATH = s:root . '/MinGit/cmd' . ';' . $PATH
    endif
    if !executable('less')
        let $PATH = s:root . '/bin' . ';' . $PATH
    endif
    let $HOME = s:root . '/home'

    " so vimrc
    source ~/vimfiles/rc.vim

    " busybox sh as &sh
    KtoggleShell
    if stridx(&sh, 'sh') < 0
        KtoggleShell
    endif

    " light theme
    set bg=light
endif

" gui init (nvim-qt)
function! s:gui_init()
    set guioptions=
    set lines=32
    set columns=128

    GuiTabline 0
endfunction

au UIEnter * call <SID>gui_init()

au FileType dirvish nmap <buffer> H <Plug>(dirvish_up) | nmap <buffer> L i
```

------------------------------------------------------------------------------

# gitconfig on Windows

```gitconfig
bb = !busybox
```

------------------------------------------------------------------------------

# END
