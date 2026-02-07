

check_container_workers() {
  status_es=$(curl -s -u "elastic:${ELASTIC_PASSWORD}" http://localhost:9200/_cluster/health | jq -r '.status')
  status_kibana=$(curl -s http://localhost:5601/api/status | jq -r '.status.overall.level')
  status_logstash_pipeline=$(curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9600)
  status_logstash_index=$(curl -s -u elastic:${ELASTIC_PASSWORD} "http://localhost:9200/host-syslog-*/_count" | jq '.count')
  local container="$1"
  local status_working="$2"
  

    echo "status working container: $status_working"


  case "$container" in
    elasticsearch)
      if [[ "$status_working" == "$status_es" ]]; then
        echo "Elasticsearch is ready with status: ${status_working}"
        return 0
      fi
      ;;
    kibana)
      if [[ "$status_working" == "$status_kibana" ]]; then
        echo "Kibana is ready with status: ${status_working}"
        return 0
      fi
      ;;
    logstash)
      if [[ "$status_working" == "$status_logstash_pipeline" || "$status_working" == "$status_logstash_index" ]]; then
        echo "Logstash is ready with status: ${status_working}"
        return 0
      fi
      fi
      ;;
    *)
      echo "Unknown container: $container"
      ;;
  esac

  return 1
}
