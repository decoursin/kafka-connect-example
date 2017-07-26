db=${DB:-kafka}
table=${TABLE:-test}
port=${PORT:-7999}

## truncate table, if it exists
exists=$(psql -U postgres -h localhost -p "$port" -c "SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');" "$db" | sed '3q;d' | cut -c2)
if [[ "$exists;" == "t;" ]]; then
	psql -U postgres -h localhost -p "$port" -c "truncate table $table;" "$db"
fi

## generate data
java -cp target/streams-1.0-SNAPSHOT-standalone.jar com.example.producers.AvroTestProducer & pid=$!
sleep 5
echo "pid: $pid"
## HOw do I do this?
##echo "lines: $(cat $file)"
kill -9 $pid

## test it
if [[ -z $(psql -U postgres -h localhost -p "$port" -f test.sql | grep bar) ]]; then
    echo "Failure!\n";
else
    echo "Success!\n";
fi
