% blog index

<!-- vim:fdm=marker {{{
# collect files
  :exe 'norm ]zj"_dG' | exe 'Cdb Sh -r git ls-files | grep -E "^[0-9]+" | sort -n -r | xargs -r -I {} sh -c "printf %s/ \"\$1\"; head -n 1 \"\$1\"" -- {}' | norm 3k
# generate WIP item
  :exe 'norm ]zj' | :.,$s/\v^(\d+)\.([^\/]+)\/\%\s*\[?WIP\]?\s*(.+)$/- \1. \*WIP\* \3/e | norm []k
# generate link
  :exe 'norm ]zj' | :.,$s/\v^(\d+)\.([^\/]+)\/\%\s*(.+)$/- \1. [\3](\1.\2)/e | norm []
}}} -->
- 0. [test](0.test.md)
