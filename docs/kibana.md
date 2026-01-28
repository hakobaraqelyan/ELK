Kibana Documentation
Overview
This document explains how Kibana is used in this project, from the initial simple setup to the finalized configuration in (feat-config-elasticsearch-kibana).
Kibana provides a web interface for interacting with Elasticsearch.
________________________________________
1. Purpose of Kibana
Kibana is used to:
•	Visualize Elasticsearch data
•	Explore indices
•	Search logs
•	Build dashboards (future)
Kibana does not store data. It only communicates with Elasticsearch.
________________________________________
2. Simple Kibana Setup (Initial Stage)
At first, Kibana was added as a basic Docker container without custom configuration.
Goals: - Confirm UI starts - Confirm it can reach Elasticsearch
________________________________________
3. Configuration File
Path:
kibana/kibana.yml
Content:
server.name: kib01
server.host: "0.0.0.0"
server.port: 5601

elasticsearch.hosts: ["http://elasticsearch:9200"]
________________________________________
4. Explanation of Configuration
server.name
Logical name of Kibana instance.
________________________________________
server.host: 0.0.0.0
Bind Kibana to all interfaces.
Why: - Allows access from host - Allows Docker networking
________________________________________
server.port: 5601
Default Kibana port.
________________________________________
elasticsearch.hosts
http://elasticsearch:9200
Why: - Uses Docker service name - Resolves inside Docker network - No need for IP addresses
________________________________________
5. Docker Compose Integration
Kibana service inside docker-compose.yml:
kibana:
  image: docker.elastic.co/kibana/kibana:8.15.0
  container_name: kibana
  volumes:
    - ./kibana/kibana.yml:/usr/share/kibana/config/kibana.yml:ro
  ports:
    - "5601:5601"
  depends_on:
    - elasticsearch
  networks:
    - elk
________________________________________
6. Startup Dependency
depends_on:
  - elasticsearch
Why: - Elasticsearch starts first - Kibana connects after ES is available
________________________________________
7. Verification Steps
Check Kibana is running
curl http://127.0.0.1:5601
Expected: HTML output.
________________________________________
Check Kibana → Elasticsearch connectivity
docker exec -it kibana curl http://elasticsearch:9200
Expected: Elasticsearch JSON response.
________________________________________
8. Result of feat-config-elasticsearch-kibana branch
Kibana:
•	Kibana uses external config file
•	Kibana connects to Elasticsearch
•	Kibana loads UI
•	No authentication required
________________________________________
9. Typical Data Flow
Browser → Kibana → Elasticsearch
________________________________________
10. Summary
Kibana in this project:
•	Runs as Docker container
•	Configured via kibana.yml
•	Connects to Elasticsearch using service name
•	Provides visualization layer
Kibana is now ready for receiving data from Elasticsearch indices created by Logstash later.

