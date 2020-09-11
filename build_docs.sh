#!/bin/sh

for dir in /input/*; do
  name=$(basename "$dir")
  echo "generating docs for $dir, outtputting to docs/$name.md"
  /usr/local/bin/terraform-docs markdown "$dir" > /output/"$name".md
done
