#!/bin/sh

for dir in /modules/*; do
  echo "generating docs for $dir, outputting to $dir/README.md"
  /usr/local/bin/terraform-docs markdown "$dir" > /$dir/README.md
done
