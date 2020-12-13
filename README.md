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

# END
