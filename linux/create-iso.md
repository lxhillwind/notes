% create iso file on linux (without root)
%
% 2023-04-07

Use `mkisofs` command from cdrtools.

(It works even inside bubblewrap!)

# example usage

```sh
mkisofs -o filename path-to-be-added-in-iso
```

See also <https://man.archlinux.org/man/mkisofs.8>
