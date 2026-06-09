#!/usr/bin/env bash
# Challenge 1 - The Log Analyst
# Generates ~/phantom/logs/app_1.log ... app_20.log with deterministic "random" data

set -euo pipefail

OUTDIR="$HOME/phantom/logs"
mkdir -p "$OUTDIR"

# Make output deterministic across runs
RANDOM=20240606

services=(auth billing cache db gateway notifier scheduler api worker)
levels=(INFO WARN ERROR DEBUG)

total=0
for i in $(seq 1 20); do
  file="$OUTDIR/app_${i}.log"
  : > "$file"
  for j in $(seq 1 1000); do
    # deterministic random seconds within 2024
    start=$(date -d "2024-01-01 00:00:00" +%s)
    end=$(date -d "2024-12-31 23:59:59" +%s)
    r=$(( (RANDOM<<15 | RANDOM) % (end - start + 1) + start ))
    ts=$(date -d "@${r}" '+%F %T')
    lvl=${levels[$((RANDOM % ${#levels[@]}))]}
    svc=${services[$((RANDOM % ${#services[@]}))]}
    total=$((total+1))
    echo "[${ts}] [${lvl}] [${svc}] message-${i}-${j}-${total}" >> "$file"
  done
done

cat <<'USAGE'
Generated logs at ~/phantom/logs (20 files × 1000 lines).

Part B — example one-liners (run in the same Cloud Shell):

Query 1: Top 3 services by ERROR count
grep -h "\[ERROR\]" ~/phantom/logs/app_*.log | awk -F'[][]' '{print $6}' | sort | uniq -c | sort -rn | head -n3

Query 2: minutes with >=2 distinct services logging ERROR
grep -h "\[ERROR\]" ~/phantom/logs/app_*.log | awk -F'[][]' '{print substr($2,1,16)"\t"$6}' | sort -u | awk -F'\t' '{cnt[$1]++} END{for(k in cnt) if(cnt[k]>=2) print k, cnt[k]}' | sort

Query 3: hour (0-23) with most log lines
awk -F'[\[\]]' '{print substr($2,12,2)}' ~/phantom/logs/app_*.log | sort | uniq -c | sort -rn | head -n1

USAGE
