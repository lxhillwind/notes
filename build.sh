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
    pandoc -r markdown+east_asian_line_breaks-yaml_metadata_block -w html --standalone -T 'lxhillwind' --mathjax --toc -H res-icon.html -B res-style.html < "$i" > "${i%.md}.html"
done < files
rm files
EOF

# generate index.html from index.md
podman exec -i pandoc pandoc -r markdown+east_asian_line_breaks-yaml_metadata_block -w html --standalone -T 'lxhillwind' -H res-icon.html < README.md > index.html
sed -E -i 's/href="(.*).md"/href=".\/\1.html"/' index.html

# generate rss;
git clone https://github.com/chambln/pandoc-rss
git -C pandoc-rss reset 52227544480facb729315ade500f77d6e5cc7657 --hard || {
    printf 'commit not found! you should check it manually.\n';
    exit 1;
}
PATH="$PWD/pandoc-rss/bin:$PATH"

git ls-files '*.md' \
    | xargs -I {} sh -c `# use -I to handle 1 line each time` \
    'date=$(sed -n "3 s/^% //p; 3q" "$0" `# line 3 contains date info`);
    [ -n "$date" ] && echo "$date" "$0";' {} `# some old essay does not contain date info` \
    | sort -rk1 `# sort by date (first column) reverse order` \
    | sed -E 's/^[0-9-]+ //' `# remove first column` \
    | xargs -L 1 pandoc-rss > rss.xml `# use -L to handle all items once` \
    -t "lxhillwind's TILs" \
    -l https://lxhillwind.github.io \
    -c 'CC BY-SA 4.0' \
    -n en
