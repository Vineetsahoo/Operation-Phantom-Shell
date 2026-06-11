#!/usr/bin/env bash
# phantom_load.sh - simple HTTP load tester in bash using curl
set -euo pipefail

usage(){
  cat <<EOF
Usage: $0 -u URL -n NUMBER -c CONCURRENCY -m METHOD -t TIMEOUT
Example: $0 -u https://httpbin.org/delay/1 -n 50 -c 10 -m GET -t 5
EOF
  exit 1
}

while getopts ":u:n:c:m:t:" opt; do
  case $opt in
    u) URL=$OPTARG ;; n) N=$OPTARG ;; c) C=$OPTARG ;; m) METHOD=$OPTARG ;; t) TIMEOUT=$OPTARG ;;
    *) usage ;;
  esac
done

if [ -z "${URL:-}" ] || [ -z "${N:-}" ] || [ -z "${C:-}" ] || [ -z "${METHOD:-}" ] || [ -z "${TIMEOUT:-}" ]; then
  usage
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"; exit' INT TERM EXIT

fifo="$tmpdir/sem"
mkfifo "$fifo"
exec 3<>"$fifo"
# seed tokens
for i in $(seq 1 $C); do printf '%s\n' "token" >&3; done

start_time=$(date +%s.%N)

for i in $(seq 1 $N); do
  read -u 3 -r token
  (
    out_file="$tmpdir/$i.out"
    # perform request, capture code and time_total
    result=$(curl -s -w "%{http_code} %{time_total}" -o /dev/null --max-time "$TIMEOUT" -X "$METHOD" "$URL" 2>/dev/null || echo "000 0")
    code=$(echo "$result" | awk '{print $1}')
    time_s=$(echo "$result" | awk '{print $2}')
    time_ms=$(awk -v t="$time_s" 'BEGIN{printf "%d", t*1000}')
    echo "$code $time_ms" > "$out_file"
    # return token
    printf '%s\n' "token" >&3
  ) &
done

wait
end_time=$(date +%s.%N)
elapsed=$(awk -v e="$end_time" -v s="$start_time" 'BEGIN{printf "%.3f", e-s}')

# aggregate
success=0
failed=0
times=()
for f in "$tmpdir"/*.out; do
  read -r code t < "$f"
  times+=($t)
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
    success=$((success+1))
  else
    failed=$((failed+1))
  fi
done

total=$((success+failed))
if [ "$total" -ne "$N" ]; then
  echo "Warning: collected $total results but expected $N"
fi

# compute stats
printf -v min "%d" 0
min=99999999; max=0; sum=0
for t in "${times[@]}"; do
  if [ $t -lt $min ]; then min=$t; fi
  if [ $t -gt $max ]; then max=$t; fi
  sum=$((sum + t))
done
avg=$(awk -v s=$sum -v n=$total 'BEGIN{printf "%.0f", s/n}')

# p95
sorted=$(printf "%s\n" "${times[@]}" | sort -n)
idx=$(awk -v n=$total 'BEGIN{printf "%d", (n*0.95==int(n*0.95)?n*0.95:int(n*0.95)+1)}')
p95=$(echo "$sorted" | sed -n "${idx}p")

throughput=$(awk -v n=$total -v e=$elapsed 'BEGIN{printf "%.2f", n/e}')

cat <<EOF
================ PHANTOM LOAD TEST REPORT =================
Target URL      : $URL
HTTP Method     : $METHOD
Total Requests  : $N
Concurrency     : $C
Timeout (s)     : $TIMEOUT
-----------------------------------------------------------
Results
-----------------------------------------------------------
Successful      : $success
Failed          : $failed
-----------------------------------------------------------
Response Times (ms)
-----------------------------------------------------------
Minimum         : $min
Maximum         : $max
Average         : $avg
P95             : $p95
-----------------------------------------------------------
Throughput      : $throughput requests/second
===========================================================
EOF
