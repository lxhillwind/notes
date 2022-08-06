<!-- vim:fdm=marker {{{
# collect files
:exe 'norm 4j"_dG' | Cdb Sh -r git ls-files | grep -E '^[0-9]+' | sort -n -r
# generate link (TODO gen title)
:exe 'norm 2j' | :.,$s/\v^(\d+)\.(.*).md$/- [\1. \2](\1.\2.md)/
}}} -->
- [0. test](0.test.md)
