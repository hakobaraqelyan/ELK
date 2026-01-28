Elasticsearch Documentation
Overview
This document describes how Elasticsearch is used in this project, starting from the simple single-node setup up to the finalized configuration implemented in (feat-config-elasticsearch-kibana).
The goal is to provide: - A clear understanding of what was configured - Why specific options were chosen - How to verify that Elasticsearch works correctly
________________________________________
1. Simple Elasticsearch Setup (Initial Stage)
At the beginning of the project, Elasticsearch was introduced as a single-node service using Docker.
Goals
•	Quickly start Elasticsearch
•	No clustering
•	No authentication
•	Easy local and server-side testing
Basic Characteristics
•	One node only
•	HTTP API exposed on port 9200
•	Security disabled
This allowed us to validate: - Docker image works - Container starts - Elasticsearch responds to HTTP requests
________________________________________
2. Elasticsearch as Part of ELK Stack
As the project evolved, Elasticsearch became part of an ELK stack:
Elasticsearch  ←  Kibana  ←  (later Logstash)
Elasticsearch is the storage and search engine of the stack.
________________________________________
3. Configuration File
Path:
elasticsearch/elasticsearch.yml
Content:
cluster.name: elk-cluster
node.name: es01

network.host: 0.0.0.0
http.port: 9200

discovery.type: single-node

xpack.security.enabled: false
xpack.security.enrollment.enabled: false
________________________________________
4. Explanation of Configuration
cluster.name
Logical name of the Elasticsearch cluster.
Why: - Helps identify cluster - Useful if more clusters appear in the future
________________________________________
node.name
Unique name of this node.
Why: - Makes logs clearer - Helpful for scaling later
________________________________________
network.host: 0.0.0.0
Bind Elasticsearch to all network interfaces.
Why: - Allows access from Docker network - Allows access from host machine
________________________________________
discovery.type: single-node
Runs Elasticsearch in single-node mode.
Why: - No cluster discovery - No bootstrap checks - Perfect for development and learning
________________________________________
xpack.security.enabled: false
Disables authentication and TLS.
Why: - Simplifies first-time setup - Avoids certificate management - Faster debugging
________________________________________
5. Docker Compose Integration
Elasticsearch service inside docker-compose.yml:
elasticsearch:
  image: docker.elastic.co/elasticsearch/elasticsearch:8.15.0
  container_name: elasticsearch
  environment:
    - discovery.type=single-node
    - xpack.security.enabled=false
    - ES_JAVA_OPTS=-Xms1g -Xmx1g
  volumes:
    - ./elasticsearch/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
    - esdata:/usr/share/elasticsearch/data
  ports:
    - "9200:9200"
  networks:
    - elk
________________________________________
6. Memory Configuration
ES_JAVA_OPTS=-Xms1g -Xmx1g
Why: - Prevents out-of-memory errors - Provides stable heap size
________________________________________
7. Data Persistence
- esdata:/usr/share/elasticsearch/data
Why: - Data survives container restart - Indexes are not lost
________________________________________
8. Verification Steps
Check Elasticsearch is running
curl http://127.0.0.1:9200
Expected: JSON with cluster information.
________________________________________
Check Cluster Health
curl http://127.0.0.1:9200/_cluster/health?pretty
Valid results:
status: yellow
or
status: green
________________________________________
9. Result of feat-config-elasticsearch-kibana branch
Elasticsearch:
•	Uses external configuration file
•	Runs in stable single-node mode
•	Accessible from Kibana
•	Cluster health is green
________________________________________
10. Summary
Elasticsearch in this project:
•	Acts as main data store
•	Runs in Docker
•	Configured via elasticsearch.yml
•	Integrated with Kibana
This forms the foundation for adding Logstash and other data producers later.

