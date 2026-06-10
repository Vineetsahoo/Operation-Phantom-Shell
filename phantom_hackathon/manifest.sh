#!/usr/bin/env bash
# manifest.sh - list files inside a .tar.gz with size and md5 without extracting
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 archive.tar.gz" >&2
  exit 2
fi
archive=$1

if ! tar -tzf "$archive" >/dev/null 2>&1; then
  echo "Error: '$archive' is not a valid tar.gz or is corrupt." >&2
  exit 3
fi

tar -tzf "$archive" | while IFS= read -r file; do
  size=$(tar -Oxzf "$archive" "$file" | wc -c)
  md5=$(tar -Oxzf "$archive" "$file" | md5sum | awk '{print $1}')
  echo "$file $size $md5"
done
