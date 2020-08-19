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

# Microsoft Windows note

## intro

How to get Linux / UNIX-like environment on Windows?

## finally

DO NOT USE WINDOWS! (auto update? old win 7?)

Or just use:
- VirtualBox
- alacritty (if gl is available) / ConEmu (vim render issue / key binding) / and pre-installed openssh
- or putty (no colorscheme / key binding).

Or, if native is required:
- mingit-busybox (cmd folder put in PATH)
- less (put in PATH)
- vim or neovim (sh / shcf set to busybox)

DO NOT use Python on Windows: package update; io performance (e.g. in vim); executable path (run script).

## meta

- All software (except msys2) does not support upgrade check.

## neovim

- ~~[X] To use plug.vim (modified), remember to set sh and shcf. (busybox ash and msys2 bash are tested and work)~~ Just use git submodule to manage plugins.

## Python

- ipython in mingw-w64 seems to be broken (Python 3.8.3, tested in 2020-06-06). Maybe we should use msvc build from
  python mirror (then pygobject is not available).

- mingw-w64 and msvc build don't support ansi code in neovim terminal. Maybe this is problem of shell?

# Git

- `less` in mingit-busybox doesn't support `-r` flag, so some command (example: `git log`) has messy output.

- But we can download binary build of `less`, and put it in `$PATH`; it will overwrite busybox-less.

- ~~mingit has no shell / coreutils (I guess).~~ It has; but `less` is not available.

- mingit (not busybox) has no readline, so sh / bash / dash key binding is terrible.

- others are too big (~40MB; but this is much smaller than msys2). (ssh, perl, tclsh is available)

# msys2

- filesystem / permission is a main problem: `chmod +x xxx.sh` has no effect.

- [X] msys2 home is different from Windows home. To solve this, we can set HOME env in shell rc.

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
    sil norm st
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

e = !~/apps/Vim/vim82/gvim
```

------------------------------------------------------------------------------

# END
