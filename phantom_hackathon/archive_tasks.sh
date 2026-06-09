#!/usr/bin/env bash
# Challenge 4 - Filesystem Archaeologist
set -euo pipefail

OUTDIR="$HOME/phantom/archive"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Part A: create 100 files of 512 bytes each (max 3 lines)
for i in $(seq -w 1 100); do dd if=/dev/urandom of=record_${i}.dat bs=512 count=1 status=none; done

# Part B: delete files whose number is prime (one-liner)
seq 2 100 | awk 'function isprime(n){if(n<2) return 0; for(i=2;i*i<=n;i++) if(n%i==0) return 0; return 1} isprime($1){printf "record_%03d.dat\n",$1}' | xargs -r rm -f

# verify remaining files count
echo "Remaining files: $(ls -1 record_*.dat | wc -l)"

# Part C: compress remaining into phantom_archive.tar.gz
cd "$OUTDIR"
tar -czf "$HOME/phantom/phantom_archive.tar.gz" record_*.dat

# Commands to answer the questions (operate on the tar.gz directly):
echo "1) Number of files: "
tar -tzf "$HOME/phantom/phantom_archive.tar.gz" | wc -l

echo "2) Total uncompressed size (bytes): "
tar -tvzf "$HOME/phantom/phantom_archive.tar.gz" | awk '{sum += $3} END{print sum}'

echo "3) Largest file inside archive: "
tar -tvzf "$HOME/phantom/phantom_archive.tar.gz" | sort -k3 -n | tail -n1

echo "4) MD5 of record_004.dat inside archive: "
tar -Oxzf "$HOME/phantom/phantom_archive.tar.gz" record_004.dat | md5sum | awk '{print $1}'
