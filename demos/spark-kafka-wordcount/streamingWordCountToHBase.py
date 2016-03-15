"""
Run with:
spark-submit --jars spark-streaming-kafka-assembly_2.10-1.5.2.jar,/usr/hdp/current/spark-client/lib/spark-examples-1.5.2.2.3.4.0-3485-hadoop2.7.1.2.3.4.0-3485.jar --driver-class-path /usr/hdp/current/hbase-client/lib/hbase-server.jar:/usr/hdp/current/hbase-client/lib/hbase-client.jar:/usr/hdp/current/hbase-client/lib/hbase-common.jar:/usr/hdp/current/hbase-client/lib/htrace-core-3.1.0-incubating.jar:/usr/hdp/current/hbase-client/lib/hbase-protocol.jar:/usr/hdp/current/hbase-client/lib/guava-12.0.1.jar /vagrant/demos/spark-kafka-wordcount/streamingWordCountToHBase.py
"""

from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

# hbase config
conf = {"hbase.zookeeper.quorum": "node1.example.com:2181,node2.example.com:2181,node3.example.com:2181",
	"hbase.mapred.outputtable": "wordcount",
        "zookeeper.znode.parent": "/hbase-unsecure",
        "mapreduce.outputformat.class": "org.apache.hadoop.hbase.mapreduce.TableOutputFormat",
        "mapreduce.job.output.key.class": "org.apache.hadoop.hbase.io.ImmutableBytesWritable",
        "mapreduce.job.output.value.class": "org.apache.hadoop.io.Writable"}
keyConv = "org.apache.spark.examples.pythonconverters.StringToImmutableBytesWritableConverter"
valueConv = "org.apache.spark.examples.pythonconverters.StringListToPutConverter"
columnFamily = "wordcount"
columnQualifier = "count"


def updateFunction(new_values, last_sum):
  return sum(new_values) + (last_sum or 0)
def toStringList(x):
  #print x[0]+"\n\n\n"
  return (x[0], [x[0], columnFamily, columnQualifier, str(x[1])])
def functionToCreateContext():
  # spark context config
  sc = SparkContext(appName="StreamingExampleWithKafka")
  ssc = StreamingContext(sc, 10)
  ssc.checkpoint("checkpoint")
  
  # kafka
  opts = {"metadata.broker.list": "node1.example.com:6667,node2.example.com:6667"}
  kvs = KafkaUtils.createDirectStream(ssc, ["mytopic"], opts)
  # processing
  lines = kvs.map(lambda x: x[1])
  counts = lines.flatMap(lambda line: line.split(" ")) \
   .map(lambda word: (word, 1)) \
   .updateStateByKey(updateFunction) \
   .map(toStringList) \
   .foreachRDD(lambda rdd: rdd.saveAsNewAPIHadoopDataset(conf=conf, keyConverter=keyConv, valueConverter=valueConv))
  return ssc

ssc = StreamingContext.getOrCreate("checkpoint", functionToCreateContext)


ssc.start()
ssc.awaitTermination()
