#!/bin/sh
set -e

# start pandoc container before running this script.
# e.g. (run it in background)
# podman run --name pandoc -v "$PWD":/data -w /data --init --rm -dt --entrypoint= docker.io/pandoc/core tail -f

# -H: --include-in-header=FILE
# -B: --include-after-body=FILE
# -A: --include-after-body=FILE
git ls-files '*.md' > files
podman exec -i pandoc sh -s <<\EOF
while read i; do
    printf 'building %s\n' "$i" >&2
    pandoc -r markdown+east_asian_line_breaks -w html --standalone -T 'lxhillwind' --mathjax --toc -H res-icon.html -B res-style.html < "$i" > "${i%.md}.html"
done < files
rm files
EOF

# generate index.html from index.md
podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks -w html --standalone -T 'lxhillwind' -H res-icon.html < README.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html
