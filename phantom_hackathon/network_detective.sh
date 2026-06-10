#!/usr/bin/env bash
# Challenge 3 - The Network Detective
set -euo pipefail

# Part A - send POST with computed header and body
# Example curl (compute inline values):
curl -s -X POST \
  -H "X-Phantom-Token: $(echo -n "phantom_$(date -u +%Y%m%d)" | base64)" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$(whoami)\", \"timestamp\": $(date -u +%s), \"checksum\": \"$(echo -n 'phantom_secret_2024' | sha256sum | awk '{print $1}')\"}" \
  https://httpbin.org/anything

# Part B - parse the response (use the same curl but pipe into parsing commands)
# 1) Extract X-Phantom-Token as server received it
curl -s -X POST -H "X-Phantom-Token: $(echo -n "phantom_$(date -u +%Y%m%d)" | base64)" -H "Content-Type: application/json" -d "{\"username\": \"$(whoami)\", \"timestamp\": $(date -u +%s), \"checksum\": \"$(echo -n 'phantom_secret_2024' | sha256sum | awk '{print $1}')\"}" https://httpbin.org/anything | sed -n 's/.*"X-Phantom-Token": "\([^"]*\)".*/\1/p'

# 2) Content-Type of the response
curl -s -D - -o /dev/null https://httpbin.org/anything | grep -i '^Content-Type:' | sed 's/Content-Type: //I'

# 3) origin IP address from response body
curl -s https://httpbin.org/anything | sed -n 's/.*"origin": "\([^"]*\)".*/\1/p'

# Part C - one-liner: 10 GETs in parallel, extract UUIDs, sort, print those where first 8 chars contain 'a'
echo "One-liner (run as single line):"
echo "seq 10 | xargs -n1 -P10 -I% sh -c 'curl -s https://httpbin.org/uuid' | sed -n 's/.*\"uuid\": \"\([^\"]*\)\".*/\1/p' | sort | awk 'substr(\$0,1,8) ~ /a/'"
