% Why does `gopls` not work without module (go.mod)
%
% 2023-07-23

Check file `~/.config/go/env` or inspect environment variable:

- Is `GO111MODULE` set to `on` or `off`? If so, unset it.

(It should work if set to `off`, but then when go.mod is available, it may not
work as expected.)

It may be set because of <https://goproxy.cn/>'s instruction.
