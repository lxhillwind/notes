#!/bin/sh
set -e

# start pandoc container before running this script.
# e.g. (run it in background)
# podman run --name pandoc --init --rm -dt --entrypoint= docker.io/pandoc/core tail -f

podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks -w html --standalone < index.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html

for i in $(sed -nE 's/^- \[.*\(([0-9]+.*.md)\)$/\1/p' index.md); do
    podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks -w html --mathjax --standalone < "$i" > "${i%.md}.html"
done
