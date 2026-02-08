#!/bin/bash

default_timer="300"
default_interval="5"
default_status_working="200"

timer="$default_timer"
interval="$default_interval"

wait_time=0

containers=()
statuses=()
statuses_working=()

usage() {
  echo "Usage:"
  echo "  $0 -s <status...> -n <containers_name...> [-i <interval>] [-t <timer>]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) timer="${2:-}"; shift 2 ;;
    -i) interval="${2:-}"; shift 2 ;;

    -n)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        containers+=("$1")
        shift
      done
      ;;

    -s)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        statuses+=("$1")
        shift
      done
      ;;

    -sw)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        statuses_working+=("$1")
        shift
      done
      ;;

    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

c_len=${#containers[@]}

for ((i=${#statuses_working[@]}; i<c_len; i++)); do
  statuses_working+=("$default_status_working")
done

echo "containers: ${containers[@]} len: ${#containers[@]}"
echo "statuses: ${statuses[@]} len: ${#statuses[@]}"
echo "statuses_working: ${statuses_working[@]}"
echo "interval: ${interval}"
echo "timer: ${timer}"
echo "c_len: ${c_len}"
echo

if [[ ${#containers[@]} -eq 0 || ${#statuses[@]} -ne $c_len ]]; then
  echo "Error: -n and -s are required"
  usage
  exit 1
fi

echo "status working container: $statuses"

index=0

while [[ $wait_time -lt $timer ]]; do
  echo "Waiting for container to be ready..."
  
  echo "Checking container ${containers[index]} with expected status: ${statuses[index]}"

  if [[ (( ""$statuses[index]"" == "${statuses_working[index]}" )) ]]; then
    echo "container ${containers[index]} is ready with status: ${statuses[index]}"
    
    index=$((index + 1))
    if [[ $index -ge $c_len ]]; then
      echo "All containers are ready."
      exit 0
    fi
  fi
  
  sleep "$interval"
  wait_time=$((wait_time + interval))
done
echo "Error: Timeout reached. Container is not ready."
exit 1