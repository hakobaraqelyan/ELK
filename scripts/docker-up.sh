#!/bin/bash

set -e
# TIMEOUT=300
# WAIT_TIME=0
# CHECK_INTERVAL=5

# while ((  WAIT_TIME < TIMEOUT)); do
#   status_es=$(docker inspect elasticsearch | jq -r '.[0].State.Status')
#   status_kibana=$(docker inspect kibana | jq -r '.[0].State.Status')
#   status_logstash=$(docker inspect logstash | jq -r '.[0].State.Status')

#   if [[
#     ${status_es} == "running" &&
#     ${status_kibana} == "running" &&
#     ${status_logstash} == "running" ]]; then
#     echo "ES and kibana containers are running"

#     status_es=$(curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health | jq -r '.status')
#     status_kibana=$(curl -s http://localhost:5601/api/status | jq -r '.status.overall.level')
#     status_logstash=$(curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9600)
#     status_logstash_index=$(curl -s -u elastic:${ELASTIC_PASSWORD} "http://localhost:9200/host-syslog-*/_count" | jq '.count')

#     echo "ES status: ${status_es}"
#     echo "Kibana status: ${status_kibana}"
#     echo "Logstash status: ${status_logstash}"
#     echo "Logstash index status: ${status_logstash_index}"

#     if [[
#     ${status_es} == "green" &&
#     ${status_kibana} == "available" &&
#     ((${status_logstash_index} > 0)) &&
#     ${status_logstash} == 200 ]]; then
    
#       echo "Elasticsearch is ready with status: ${status_es}"
#       echo "Kibana is ready with status: ${status_kibana}"
#       echo "Logstash is ready with workers: ${status_logstash}"
#       exit 0
#     fi
#   fi

#   sleep ${CHECK_INTERVAL}
#     WAIT_TIME=$((  WAIT_TIME + 1));
#   if ((  WAIT_TIME == TIMEOUT)); then
#     echo "Elasticsearch, Kibana and Logstash did not become ready in time"
#     exit 1
#   fi
# done



set -euo pipefail

default_command="up -d"
default_timer="300"
default_wait="5"
default_status="running"

command="$default_command"
timer="$default_timer"
wait_time="$default_wait"

containers=()
statuses=()

usage() {
  echo "Usage: $0 -n <containers...> [-s <statuses...>] [-c \"cmd\"] [-t seconds] [-w seconds]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c) command="${2:-}"; shift 2 ;;
    -t) timer="${2:-}"; shift 2 ;;
    -w) wait_time="${2:-}"; shift 2 ;;
    -n)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        containers+=("$1"); shift
      done
      ;;
    -s)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        statuses+=("$1"); shift
      done
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ ${#containers[@]} -eq 0 ]]; then
  echo "Error: -n is required"; usage; exit 1
fi


c_len=${#containers[@]}
s_len=${#statuses[@]}

normalized_statuses=()

if [[ $s_len -eq 0 ]]; then
  for ((i=0; i<c_len; i++)); do
    normalized_statuses+=("$default_status")
  done

elif [[ $s_len -eq 1 ]]; then
  for ((i=0; i<c_len; i++)); do
    normalized_statuses+=("${statuses[0]}")
  done

else
  for ((i=0; i<c_len; i++)); do
    if [[ $i -lt $s_len ]]; then
      normalized_statuses+=("${statuses[$i]}")
    else
      normalized_statuses+=("$default_status")
    fi
  done
fi


statuses=("${normalized_statuses[@]}")

echo "command=$command"
echo "timer=$timer"
echo "wait=$wait_time"
echo

echo "Paired (container -> status):"
for i in "${!containers[@]}"; do
  printf '  %s -> %s\n' "${containers[$i]}" "${statuses[$i]}"
done

check_containers(${containers}, ${statuses}, ${timer}, ${wait_time})


check_containers() {
  local containers="$1"
  local statuses="$2"
  local TIMEOUT="$3"
  local WAIT_TIME="$4"
  
  
  while ((  WAIT_TIME < TIMEOUT)); do
    status_es=$(docker inspect elasticsearch | jq -r '.[0].State.Status')
    status_kibana=$(docker inspect kibana | jq -r '.[0].State.Status')
    status_logstash=$(docker inspect logstash | jq -r '.[0].State.Status')

    if [[
      ${status_es} == "running" &&
      ${status_kibana} == "running" &&
      ${status_logstash} == "running" ]]; then
      echo "ES and kibana containers are running"

      status_es=$(curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health | jq -r '.status')
      status_kibana=$(curl -s http://localhost:5601/api/status | jq -r '.status.overall.level')
      status_logstash=$(curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9600)
      status_logstash_index=$(curl -s -u elastic:${ELASTIC_PASSWORD} "http://localhost:9200/host-syslog-*/_count" | jq '.count')

      echo "ES status: ${status_es}"
      echo "Kibana status: ${status_kibana}"
      echo "Logstash status: ${status_logstash}"
      echo "Logstash index status: ${status_logstash_index}"

      if [[
      ${status_es} == "green" &&
      ${status_kibana} == "available" &&
      ((${status_logstash_index} > 0)) &&
      ${status_logstash} == 200 ]]; then
      
        echo "Elasticsearch is ready with status: ${status_es}"
        echo "Kibana is ready with status: ${status_kibana}"
        echo "Logstash is ready with workers: ${status_logstash}"
        exit 0
      fi
    fi

    sleep ${CHECK_INTERVAL}
      WAIT_TIME=$((  WAIT_TIME + 1));
    if ((  WAIT_TIME == TIMEOUT)); then
      echo "Elasticsearch, Kibana and Logstash did not become ready in time"
      exit 1
    fi
  done

}
