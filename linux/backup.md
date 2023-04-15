% linux backup step (desktop pc; backups user home)
%
% 2023-04-15

# step 1: check how large each directory / file is

add which not worth backup to rg regex list manually. (**it's better to put
the regex list in a file, for privacy reason**)

```sh
\ls -A ~ | rg -v '^('"$(cat ~/backup-list.txt | tr '\n' '|')"')$' | tr '\n' '\0' | du -csh --files0-from=- | sort -hk1
```

# step2: backup file to a directory outside of backup content

If memory is large enough, just backup to /tmp (and it should be faster than
backup to disk).

```sh
tar -acf "/tmp/bak-$(date +%F).tar" -X ~/backup-list.txt -C ~ .
```

# step3: encrypt the backup file (optional)

```sh
cd /tmp  # go to dir of backup tar, so we can create archive of file without slash in path.
7z a -mx=0 -p"$(python3 -c 'import getpass; print(getpass.getpass())')" /external-device-directory/"home-pc-bak-$(date +%F).7z" bak-$(date +%F).tar
```

# step4: move backup file to external device

(may be done already in step3)
