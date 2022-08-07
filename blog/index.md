% blog index

<!-- vim:fdm=marker {{{
# collect files
:exe 'norm 4j"_dG' | Cdb Sh -r git ls-files | grep -E '^[0-9]+' | sort -n -r | xargs -r -I {} sh -c 'printf "%s/" "$1"; head -n 1 "$1"' -- {}
# generate link
:exe 'norm 2j' | :.,$s/\v^(\d+)\.([^\/]+)\/\%\s*(.+)$/- [\1. \3](\1.\2)/
}}} -->
- [0. test](0.test.md)
