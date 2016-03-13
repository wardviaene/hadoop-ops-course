package io.in4it.edwardviaene.storm;


import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.task.ShellBolt;
import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.IRichBolt;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import backtype.storm.spout.SchemeAsMultiScheme;
import backtype.storm.task.OutputCollector;
import storm.kafka.BrokerHosts;
import storm.kafka.ZkHosts;
import storm.kafka.StringScheme;
import storm.kafka.trident.OpaqueTridentKafkaSpout;
import storm.kafka.trident.TridentKafkaConfig;
import storm.kafka.trident.mapper.FieldNameBasedTupleToKafkaMapper;
import storm.kafka.trident.selector.DefaultTopicSelector;
import storm.kafka.trident.TridentKafkaStateFactory;
import storm.kafka.trident.TridentKafkaState;
import storm.kafka.trident.TridentKafkaUpdater;
import storm.trident.TridentTopology;
import storm.trident.TridentState;
import storm.trident.operation.builtin.Count;
import storm.trident.tuple.TridentTuple;
import storm.trident.operation.BaseFunction;
import storm.trident.operation.TridentCollector;
import storm.trident.testing.MemoryMapState;

import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.UUID;
import java.util.Properties;


public class TridentWordCountTopology {
  public static class Split extends BaseFunction {
    @Override
    public void execute(TridentTuple tuple, TridentCollector collector) {
      String sentence = tuple.getString(1);
      for (String word : sentence.split(" ")) {
        collector.emit(new Values(word));
      }
    }
  }
  public static void main(String[] args) throws Exception {

    Config conf = new Config();
    TridentTopology topology = new TridentTopology();
    BrokerHosts hosts = new ZkHosts("node1.example.com:2181");
    TridentKafkaConfig spoutConfig = new TridentKafkaConfig(hosts, "mytopic");
    spoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());
    OpaqueTridentKafkaSpout kafkaSpout = new OpaqueTridentKafkaSpout(spoutConfig);

    TridentKafkaStateFactory kafkaStateFactory = new TridentKafkaStateFactory()
                .withKafkaTopicSelector(new DefaultTopicSelector("mytopic2"))
                .withTridentTupleToKafkaMapper(new FieldNameBasedTupleToKafkaMapper("word", "count"));

    TridentState wordCounts = topology.newStream("spout1", kafkaSpout)
         .each(kafkaSpout.getOutputFields(), new Split(), new Fields("word"))
         .groupBy(new Fields("word"))
         .persistentAggregate(kafkaStateFactory, new Count(), new Fields("count"))
         .parallelismHint(2);

    // kafka output bolt
    Properties props = new Properties();
    props.put("metadata.broker.list", "node1.example.com:6667");
    props.put("serializer.class", "kafka.serializer.StringEncoder");
    conf.put(TridentKafkaState.KAFKA_BROKER_PROPERTIES, props);

    conf.setDebug(true);

    if (args != null && args.length > 0) {
      conf.setNumWorkers(3);

      StormSubmitter.submitTopologyWithProgressBar(args[0], conf, topology.build());
    }
    else {
      conf.setMaxTaskParallelism(3);

      LocalCluster cluster = new LocalCluster();
      cluster.submitTopology("word-count", conf, topology.build());

      Thread.sleep(10000);

      cluster.shutdown();
    }
  }
}
