#!/usr/bin/env bash
# Challenge 4 - Filesystem Archaeologist
set -euo pipefail

OUTDIR="$HOME/phantom/archive"
mkdir -p "$OUTDIR"
mkdir -p "$HOME/phantom" # Ensure the parent directory for the tarball exists
cd "$OUTDIR"

# Part A: create 100 files of 512 bytes each
# Using %03d here explicitly to match exactly 3 digits (001 to 100)
for i in $(seq 1 100); do 
    printf -v filename "record_%03d.dat" "$i"
    dd if=/dev/urandom of="$filename" bs=512 count=1 status=none
done

# Part B: delete files whose number is prime (one-liner)
# Fixed to ensure it properly generates 3-digit padded arguments for rm
seq 2 100 | awk 'function isprime(n){if(n<2) return 0; for(i=2;i*i<=n;i++) if(n%i==0) return 0; return 1} isprime($1){printf "record_%03d.dat\n",$1}' | xargs -r rm -f

# verify remaining files count
echo "Remaining files: $(ls -1 record_*.dat 2>/dev/null | wc -l || echo 0)"

# Part C: compress remaining into phantom_archive.tar.gz
# Using find ensures we don't break if the wildcard expansion gets too long
find . -maxdepth 1 -name "record_*.dat" -print0 | tar -czf "$HOME/phantom/phantom_archive.tar.gz" --null -T -

# Commands to answer the questions (operate on the tar.gz directly):
echo "1) Number of files: "
tar -tzf "$HOME/phantom/phantom_archive.tar.gz" | wc -l

echo "2) Total uncompressed size (bytes): "
tar -tvzf "$HOME/phantom/phantom_archive.tar.gz" | awk '{sum += $3} END{print sum}'

echo "3) Largest file inside archive: "
tar -tvzf "$HOME/phantom/phantom_archive.tar.gz" | sort -k3 -n | tail -n1

echo "4) MD5 of record_004.dat inside archive: "
# FIXED: Moved the 'f' flag to the absolute end of the short-options group
tar -xOzf "$HOME/phantom/phantom_archive.tar.gz" record_004.dat | md5sum | awk '{print $1}'