* Build with: mvn build
* Run with: storm jar target/storm-kafka-wordcount-1.0.0-SNAPSHOT.jar io.in4it.edwardviaene.storm.WordCountTopology production-topology remote
* Generate some input with: /usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list node1.example.com:6667 --topic mytopic
* Check for output with: /usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh  --zookeeper node1.example.com:2181 --topic mytopic2 —from-beginning --property print.key=true --property key.separator=,
