#!/usr/bin/env bash
# phantom_monitor.sh - single-file monitor that spawns 5 workers

set -euo pipefail

WORKERS=5
declare -a PIDS
declare -a HEARTBEATS

tmpdir=/tmp/phantom_monitor_$$
mkdir -p "$tmpdir"

cleanup() {
  rm -rf "$tmpdir"
}

trap 'echo "Shutdown received: stopping workers..."; shutdown; exit 0' INT TERM

shutdown() {
  for pid in "${PIDS[@]}"; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  # wait for children to exit
  sleep 0.5
  for pid in "${PIDS[@]}"; do
    if [ -n "$pid" ]; then
      wait "$pid" 2>/dev/null || true
    fi
  done
  echo "All workers stopped. Exiting monitor."
  cleanup
}

worker_loop(){
  id=$1
  logfile="/tmp/worker_${id}.log"
  count=0
  while true; do
    sleep $(( (RANDOM % 7) + 2 ))
    count=$((count+1))
    printf '[%s] worker-%d heartbeat %d\n' "$(date '+%F %T')" "$id" "$count" >> "$logfile"
  done
}

spawn_worker(){
  id=$1
  worker_loop "$id" &
  pid=$!
  PIDS[$id]=$pid
}

# seed deterministic-ish randomness for repeatability during a run
RANDOM=$$

for i in $(seq 1 $WORKERS); do
  PIDS[$i]=''
  spawn_worker $i
done

last_status=0
while true; do
  # check workers every second, print full status every 10s
  for i in $(seq 1 $WORKERS); do
    pid=${PIDS[$i]}
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
      echo "Worker-$i (pid ${pid:-none}) died; restarting..."
      spawn_worker $i
    fi
  done

  now=$(date '+%s')
  if (( now - last_status >= 10 )); then
    echo "---- PHANTOM MONITOR STATUS [$(date '+%F %T')] ----"
    printf "PID\tWORKER-ID\tHEARTBEATS\tLAST-SEEN\n"
    for i in $(seq 1 $WORKERS); do
      pid=${PIDS[$i]}
      logfile="/tmp/worker_${i}.log"
      hb=0
      last="-"
      if [ -f "$logfile" ]; then
        hb=$(wc -l < "$logfile" 2>/dev/null || echo 0)
        last=$(tail -n1 "$logfile" 2>/dev/null | awk -F'[][]' '{print $2}' || echo '-')
      fi
      printf "%s\tworker-%d\t%s\t%s\n" "${pid:--}" "$i" "$hb" "$last"
    done
    last_status=$now
  fi

  sleep 1
done
