#!/bin/bash

set -euo pipefail

default_command="up -d"
default_timer="300"
default_interval="5"
default_status="running"
default_status_working="200"

command="$default_command"
timer="$default_timer"
interval="$default_interval"

containers=()
statuses=()
status_working=()

usage() {
  echo "Usage:"
  echo "  $0 -n <containers...> [-s <statuses...>] [-sw <codes...>]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c) command="${2:-}"; shift 2 ;;
    -t) timer="${2:-}"; shift 2 ;;
    -w) interval="${2:-}"; shift 2 ;;

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
        status_working+=("$1")
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

if [[ ${command} == "up -d" ]]; then
  if [[ ${#containers[@]} -eq 0 ]]; then
    echo "Error: -n is required"
    exit 1
  fi
fi

c_len=${#containers[@]}

if [[ ${#statuses[@]} -eq 0 ]]; then
  for ((i=0; i<c_len; i++)); do
    statuses+=("$default_status")
  done
fi

if [[ ${#status_working[@]} -eq 0 ]]; then
  for ((i=0; i<c_len; i++)); do
    status_working+=("$default_status_working")
  done
fi

for ((i=${#statuses[@]}; i<c_len; i++)); do
  statuses+=("$default_status")
done

for ((i=${#status_working[@]}; i<c_len; i++)); do
  status_working+=("$default_status_working")
done



check_containers() {
  local container="$1"
  local statuses="$2"
  local status_working="$3"
  
  echo "container: ${container}"
  echo "status: ${statuses}"
  echo

  status_container=$(docker inspect "$container" | jq -r '.[0].State.Status')
  echo "$status_container"
  if [[ ${status_container} == ${statuses} ]]; then
    echo "Container $container is running"

    if check_container_workers "$container" "$status_working"; then
      return 0
    else
      return 1
    fi
  fi
  return 1
}

# check_container_workers() {
#   local container="$1"
#   local status_working="$2"

    

#     echo "status working container: $status_working"
      
#   if [[ "$status_working" ]]; then
  
#     echo "container is ready with status: ${status_working}"

#     return 0
#   fi

#   return 1
# }

source ./scripts/check-workers.sh

wait_time=0
index=0

echo "containers is ${command}"
docker compose ${command}

while ((  wait_time < timer)); do

  if [[ ${command} == "up -d" ]]; then
    
    if [[ ${index} -lt ${c_len} ]]; then
                                  
      if check_containers "${containers[$index]}" "${statuses[$index]}" "${status_working[$index]}" "$timer" "$interval"; then
        echo "index: ${index}"
        index=$((index + 1))
      else
          sleep ${interval} 
          wait_time=$((  wait_time + interval));
      fi
    elif ((  index >= c_len)); then
      echo "All containers are ready"
      exit 0        
    fi
  elif [[ ${command} == "down" || ${command} == "down -v" || ${command} == "down --volumes" || ${command} == "down --remove-orphans --volumes" ]]; then
    echo "Checking if containers are down"
    if ! [[ $(docker compose ps -q) ]]; then
      echo "All containers are down"
      exit 0
    else
      sleep ${interval}
      wait_time=$((  wait_time + interval));
    fi
  fi

  if ((  wait_time == timer)); then
    echo "Elasticsearch, Kibana and Logstash did not become ready in time"
    exit 1
  fi
done



