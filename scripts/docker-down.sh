TIMEOUT=120
WAIT_TIME=0
CHECK_INTERVAL=5

  while ((  WAIT_TIME < TIMEOUT)); do
  status_es=$(docker inspect elasticsearch | jq -r '.[0].State.Status')
  status_kibana=$(docker inspect kibana | jq -r '.[0].State.Status')
  status_logstash=$(docker inspect logstash | jq -r '.[0].State.Status')

  if [[ ${status_es} == "null" || ${status_kibana} == "null" || ${status_logstash} == "null" ]]; then
    echo "Elasticsearch, Kibana and Logstash is down"
    exit 0
  fi

  sleep ${CHECK_INTERVAL}
  WAIT_TIME=$((  WAIT_TIME + 1));
  
  if ((  WAIT_TIME == TIMEOUT)); then
    echo "ES, Kibana and Logstash did not become ready in time"
    exit 1
  fi
  done