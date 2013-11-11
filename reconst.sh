#!/usr/bin/bash

# Script to get top-resolution page images from Rolling Stone's archive

# Handle exit interrupts at the script level
trap "exit" INT

# I'm not including my account's request token in the script, obviously.

# If you want to find your own, hint: the archive viewer requests some data
# through the browser's network facilities. The WebKit Inspector lets you
# see the URLs of all requested resources on the Network tab. Solve for X.

echo "Enter your request token:"
read token

issue="19721207"

# Pages of the article
# include page 1 for the article's inside-cover image
pages="1 50 51 52 54 56 58"

# Tiling stats
level=13
rows=5
cols=4

suffix=".jpg"

for page in $pages; do
  mkdir -p $page
  for ((row = 0; row < rows; row++)); do
    for ((col = 0; col < cols; col++)); do
      echo "Getting $page/${row}_${col} ..."
      curl http://archive.rollingstone.com/Collection/token=$token/$issue/compositions/$page.0_files/$level/${col}_${row}.jpg > $page/${row}_${col}$suffix
    done
  done
  # the -1-1 geometry is to eliminate / reduce the number of shared edge pixels
  # (some tile rows/cols share deeper edge pixel rows/cols with other tiles,
  #  but this can't easily be fixed at the montage concatenate level)
  echo "Stitching..."
  montage -mode concatenate -tile ${cols}x${rows} -geometry -1-1 $page/*$suffix $page$suffix
done
