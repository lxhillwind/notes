% newline ("\r\n" or "\n"?) in some programming languages
%
% 2022-11-13

# background

newline is `\r\n` in windows, and `\n` in unix-like systems (macOS, Linux,
etc). This is why a text file created in unix-like systems, when opened with
windows notepad, shows all lines in a single line (seems "fixed" in windows
10?).

# how I find the problem

I keep writing some small scripts / utils (like this:
<https://github.com/lxhillwind/utils/tree/main/find-repo> and this
<https://github.com/lxhillwind/dotfiles/tree/main/bin>) for OS I'm using.

Today, I try to rewrite a nim script
[find-repo](https://github.com/lxhillwind/utils/tree/main/find-repo) in
python. When using it from vim plugin
[vim-fuzzy](https://github.com/lacygoill/vim-fuzzy), the result is weird.
While running it in terminal, it looks normal...

After comparing the outputs generated from old (nim) and new (python)
implementation (`vim -d <(xxx) <(yyy)`), I finally find that it is because
python `print` function will end with `\r\n` in windows. And this is
un-avoidable! Using `print(xxx, end="\n")` won't fix.

# compare between different impl

Then, how do different programming languages output newline?

**NOTE: I test these in git-for-windows bash.**
python example:

```sh
python3 -c 'import sys; sys.stdout.write("hello\n"); sys.stdout.write("world\n")' | tr '\r' '|'

# gives:
# hello|
# world|
```

Some simple test shows that:

- zig gives `\n` (TODO: needs inspection, since I print "\n" in
  `std.debug.print` directly...);

- nim gives `\n` (with `echo` proc);

- python gives `\r\n` (with `print` function / `sys.stdout.write(xxx + "\n")`);

# more about running environment

I found the `\r\n` problem in vim's job API (which I believe is ConPTY: since
I don't have winpty installed).

Ah wait! I actually run it with `&shell` setting to `git bash`... So winpty is
invoked anyway.

test with `&shell` not set (default to cmd.exe) also don't work.

So this is not related to winpty / git-bash.

# why these behave differently

TODO
