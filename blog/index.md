<!-- vim:fdm=marker {{{
# collect files
:exe 'norm 4j"_dG' | Cdb Sh -r git ls-files | grep -E '^[0-9]+' | sort -n -r
# generate link (TODO gen title)
:exe 'norm 2j' | :.,$s/^.*$/- [&](&)/
}}} -->
- [0.test.md](0.test.md)
