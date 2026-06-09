# Operation Phantom Shell

This folder contains one bash solution per challenge. Run everything in Google
Cloud Shell or another Linux environment with standard GNU utilities.

## Challenge 1 - The Log Analyst

Files:
- [challenge1_generate_logs.sh](challenge1_generate_logs.sh)

What it does:
- Creates `~/phantom/logs/app_1.log` through `app_20.log`
- Generates 20,000 deterministic log lines
- Prints the exact one-liners used for the three queries

Run:
```bash
chmod +x phantom_hackathon/challenge1_generate_logs.sh
./phantom_hackathon/challenge1_generate_logs.sh
```

Verify with the printed one-liners for:
- Top 3 services by `ERROR`
- Minutes with `ERROR` from 2+ distinct services
- Hour of day with the most log lines

## Challenge 2 - The Process Wrangler

Files:
- [phantom_monitor.sh](phantom_monitor.sh)

What it does:
- Spawns exactly 5 background workers
- Prints a status report every 10 seconds
- Restarts a worker if it dies
- Handles `SIGINT` and `SIGTERM` cleanly

Run:
```bash
chmod +x phantom_hackathon/phantom_monitor.sh
./phantom_hackathon/phantom_monitor.sh
```

Verification checklist:
- Let it run at least 60 seconds
- Kill one worker PID and confirm the monitor restarts it
- Press Ctrl+C and confirm shutdown text appears
- Run `ps aux | grep phantom_monitor` and `ps aux | grep worker` after exit

## Challenge 3 - The Network Detective

Files:
- [network_detective.sh](network_detective.sh)

What it does:
- Sends the required POST request to `https://httpbin.org/anything`
- Computes the `X-Phantom-Token`, username, timestamp, and checksum inline
- Shows the response parsing commands using `grep`, `awk`, `sed`, and `tr`
- Includes the required UUID one-liner for Part C

Run:
```bash
chmod +x phantom_hackathon/network_detective.sh
./phantom_hackathon/network_detective.sh
```

Important values verified by the script output:
- Request body JSON fields are computed, not hardcoded
- `httpbin` echoes the token in the response body
- `Content-Type` is printed from the response headers
- `origin` is printed from the response body

## Challenge 4 - The Filesystem Archaeologist

Files:
- [archive_tasks.sh](archive_tasks.sh)
- [manifest.sh](manifest.sh)

What it does:
- Creates 100 files of 512 bytes each in 3 lines or fewer
- Deletes prime-numbered files with a one-liner
- Builds `~/phantom/phantom_archive.tar.gz`
- Inspects the archive without extracting it
- Lists filename, size, and MD5 for every file in the archive

Run:
```bash
chmod +x phantom_hackathon/archive_tasks.sh phantom_hackathon/manifest.sh
./phantom_hackathon/archive_tasks.sh
./phantom_hackathon/manifest.sh ~/phantom/phantom_archive.tar.gz
```

Bonus check:
- Corrupt a copy of the archive and run `manifest.sh` against it
- The script should print a clear error and exit non-zero

## Challenge 5 - The Final Boss

Files:
- [phantom_load.sh](phantom_load.sh)

What it does:
- Accepts `-u`, `-n`, `-c`, `-m`, and `-t`
- Enforces concurrency with a token-based semaphore
- Measures request latency in milliseconds
- Reports success/failure, min/max/avg, P95, and throughput

Run the required verification command:
```bash
chmod +x phantom_hackathon/phantom_load.sh
./phantom_hackathon/phantom_load.sh -u https://httpbin.org/delay/1 -n 50 -c 10 -m GET -t 5
```

## Quick File List

- [challenge1_generate_logs.sh](challenge1_generate_logs.sh)
- [phantom_monitor.sh](phantom_monitor.sh)
- [network_detective.sh](network_detective.sh)
- [archive_tasks.sh](archive_tasks.sh)
- [manifest.sh](manifest.sh)
- [phantom_load.sh](phantom_load.sh)

