#!/bin/sh
set -e

# start pandoc container before running this script.
# e.g. (run it in background)
# podman run --name pandoc --init --rm -dt --entrypoint= docker.io/pandoc/core tail -f

podman exec -i pandoc pandoc -r gfm -w html --embed-resources --standalone --metadata title='blog index' < index.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html

for i in $(\ls | grep -E '^[0-9]+.*.md$'); do
    title=${i%.md}
    title=${title#*.}
    podman exec -i pandoc pandoc -r gfm -w html --embed-resources --standalone --metadata title="$title" < "$i" > "${i%.md}.html"
done
