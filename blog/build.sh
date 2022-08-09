#!/bin/sh
set -e

# start pandoc container before running this script.
# e.g. (run it in background)
# podman run --name pandoc --init --rm -dt --entrypoint= docker.io/pandoc/core tail -f

# put some file into container.
for i in res-*.html; do
    podman exec -i pandoc sh -c "cat > $i" < "$i"
done

podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks -w html --standalone -T 'lxhillwind' -H res-icon.html < index.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html

for i in $(sed -nE 's/^- .*\[.*\(([0-9]+.*.md)\)$/\1/p' index.md); do
    # -H: --include-in-header=FILE
    # -B: --include-after-body=FILE
    # -A: --include-after-body=FILE
    podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks -w html --standalone -T 'lxhillwind' --mathjax --toc -H res-icon.html -B res-style.html < "$i" > "${i%.md}.html"
done
