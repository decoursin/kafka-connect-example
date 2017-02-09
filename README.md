# Kafka Connect Example

1) Install Confluent on your company (needed for some of the scripts)

2) run `./kafka-start` to start docker containers

3) start the connectors by running:
- `./create-connector.sh test` 
- `./create-connector.sh test2`

4) package it: `mvn package`

4) Run `TestProcessor.java`
- mvn pa

5) Run the `AvroTestProducer.java` to produce commands.

6) Check if the data is replicated to postgres
- `psql -U postgres -h localhost -p 7999`
- `\connect kafka`
- `select * from test;`
- `select * from test2;`
