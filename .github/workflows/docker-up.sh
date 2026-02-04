#!/bin/bash

set -e
TIMEOUT=300
WAIT_TIME=0
CHECK_INTERVAL=5

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
