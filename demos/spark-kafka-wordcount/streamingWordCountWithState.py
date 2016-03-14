from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

def updateFunction(new_values, last_sum):
  return sum(new_values) + (last_sum or 0)
def functionToCreateContext():
  sc = SparkContext(appName="StreamingExampleWithKafka")
  ssc = StreamingContext(sc, 10)
  ssc.checkpoint("checkpoint")
  opts = {"metadata.broker.list": "node1.example.com:6667,node2.example.com:6667"}
  kvs = KafkaUtils.createDirectStream(ssc, ["mytopic"], opts)
  lines = kvs.map(lambda x: x[1])
  counts = lines.flatMap(lambda line: line.split(" ")) \
   .map(lambda word: (word, 1)) \
   .updateStateByKey(updateFunction)
  counts.pprint()
  return ssc

ssc = StreamingContext.getOrCreate("checkpoint", functionToCreateContext)


ssc.start()
ssc.awaitTermination()
