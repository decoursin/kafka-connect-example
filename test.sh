db=${DB:-kafka}
table=${TABLE:-test}
port=${PORT:-7999}

generate_create_connector_post_data()
{
    cat <<EOF
{
    "name": "$table",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:postgresql://localhost:7999/kafka?user=postgres&password=",
        "topics": "$table",
        "poll.interval.ms": 1000,
        "auto.create": true,
        "auto.evolve": true 
    }
}
EOF
}

create_jdbc_sink_connector()
{
    response_code=$(curl --silent --show-error \
                         -X GET \
                         --write-out '%{http_code}' \
                         --output /dev/null \
                         -H "Accept: application/json" \
                         -H "Content-Type: application/json" \
                         "http://localhost:8083/connectors/$table/status")

    if (( response_code != 200 )); then
        echo "creating connector.."
        curl -X POST \
             -H "Content-Type: application/json" \
             --data "$(generate_create_connector_post_data)" \
             "http://localhost:8083/connectors"
    fi
}

truncate_table()
{
    exists=$(psql -U postgres -h localhost -p "$port" -c "SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');" "$db" | sed '3q;d' | cut -c2)

    if [[ "$exists;" == "t;" ]]; then
        psql -U postgres -h localhost -p "$port" -c "truncate table $table;" "$db"
    fi
    
}

create_jdbc_sink_connector

truncate_table

## generate data
java -cp target/streams-1.0-SNAPSHOT-standalone.jar com.example.producers.AvroTestProducer $table & pid=$!
sleep 4
## HOw do I do this?
##echo "lines: $(cat $file)"
kill -9 $pid

## test it
if [[ -z $(psql -U postgres -h localhost -p "$port" -c "select * from $table" $db | grep bar) ]]; then
    echo "Failure!\n";
else
    echo "Success!\n";
fi
