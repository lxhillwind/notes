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

# todo

```todo

- edit
    - highlight
    - shortcut (add new pre)
    - format (keep all pres not indented)
- apply style (via JavaScript if supported)

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

# vimrc on Windows

```vim
so ~/lib/rc.vim

if !get(g:, 'vimrc_loaded')
    let g:vimrc_loaded = 1
    set guioptions=
    set gfn=Consolas:h11:cANSI:qDRAFT
    set lines=32
    set columns=128

    if !executable('git')
        let $PATH = expand('~/apps/MinGit/cmd') . ';' . $PATH
    endif
endif

command! KtoggleShell call <SID>ToggleShell()
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

sil normal st
```

------------------------------------------------------------------------------

# gitconfig on Windows

```gitconfig

bb = !busybox

e = !~/apps/Vim/vim82/gvim

```

------------------------------------------------------------------------------

# END
