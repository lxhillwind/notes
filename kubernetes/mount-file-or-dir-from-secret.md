% mount file or dir from secret
%
% 2022-11-23

see <https://kubernetes.io/docs/concepts/configuration/secret/>

some tips:

- We want to mount sth, and write to directory of it.

Suppose we mount something to `.ssh/` directory: we can't write anything to
files under it, say, `.ssh/config`, even if we set permission to `07??`.

Then we should mount file(s) instead of directory. Use
[subpath](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath)
to mount the desired file.

- What if we only want to use some (not all) key(s) from secret?

Configure `.spec.volumes[].secret.items`.
