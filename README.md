Tasks:
    1. Create automation with github actions which will deploy the infra with docker-compose container
    2. Create Docker compose file which will deploy Elasticsearch + logstash + kibana and configure all 3
    3. Collect logs from syslog and auth.log

files structure
ELK/
  docker-compose.yml

  elasticsearch/
    elasticsearch.yml

  logstash/
    pipeline/
      logs.conf

  kibana/
    kibana.yml

  .github/
    workflows/
      deploy.yml