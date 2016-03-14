from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
sc = SparkContext(appName="StreamingExampleWithKafka")
ssc = StreamingContext(sc, 10)
opts = {"metadata.broker.list": "node1.example.com:6667,node2.example.com:6667"}
kvs = KafkaUtils.createDirectStream(ssc, ["mytopic"], opts)
lines.pprint()
counts = lines.flatMap(lambda line: line.split(" ")) \
 .map(lambda word: (word, 1)) \
 .reduceByKey(lambda a, b: a+b)
counts.pprint()
ssc.start()
ssc.awaitTermination()
