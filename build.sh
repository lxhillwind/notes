#!/bin/sh
set -e

# start pandoc container before running this script.
# e.g. (run it in background)
# podman run --name pandoc -v "$PWD":"$PWD" -w "$PWD" --init --rm -dt --entrypoint= docker.io/pandoc/core tail -f

if ! command -v pandoc >/dev/null; then
    printf '%s\n' 'exec podman exec -i pandoc pandoc "$@"' > /usr/local/bin/pandoc
    chmod +x /usr/local/bin/pandoc
fi

# -H: --include-in-header=FILE
# -B: --include-after-body=FILE
# -A: --include-after-body=FILE
git ls-files '*.md' | \
    while read i; do
        printf 'building %s\n' "$i" >&2
        pandoc -r markdown+east_asian_line_breaks-yaml_metadata_block -w html --standalone -T 'lxhillwind' --mathjax --toc -H res-icon.html -B res-style.html < "$i" > "${i%.md}.html"
    done

# generate index.html from index.md
pandoc -r markdown+east_asian_line_breaks-yaml_metadata_block -w html --standalone -T 'lxhillwind' -H res-icon.html < README.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html
