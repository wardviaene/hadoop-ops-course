package io.in4it.edwardviaene.storm;


import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.task.ShellBolt;
import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.IRichBolt;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import backtype.storm.spout.SchemeAsMultiScheme;
import backtype.storm.task.OutputCollector;
import storm.kafka.BrokerHosts;
import storm.kafka.ZkHosts;
import storm.kafka.SpoutConfig;
import storm.kafka.StringScheme;
import storm.kafka.KafkaSpout;
import storm.kafka.bolt.KafkaBolt;
import storm.kafka.bolt.mapper.FieldNameBasedTupleToKafkaMapper;
import storm.kafka.bolt.selector.DefaultTopicSelector;

import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.UUID;
import java.util.Properties;


public class WordCountTopology {
  public static class SplitSentence extends BaseBasicBolt {
  
    @Override
    public void execute(Tuple tuple, BasicOutputCollector collector) {
        StringTokenizer itr = new StringTokenizer(tuple.getString(0));
        while (itr.hasMoreTokens()) {
          collector.emit(new Values(itr.nextToken()));
        }
    }
  
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }    
  }

  public static class WordCount extends BaseBasicBolt {
    Map<String, Integer> counts = new HashMap<String, Integer>();

    @Override
    public void execute(Tuple tuple, BasicOutputCollector collector) {
      String word = tuple.getString(0);
      Integer count = counts.get(word);
      if (count == null)
        count = 0;
      count++;
      counts.put(word, count);
      collector.emit(new Values(word, count));
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
      declarer.declare(new Fields("word", "count"));
    }
  }

  public static void main(String[] args) throws Exception {

    Config conf = new Config();
    TopologyBuilder builder = new TopologyBuilder();
    BrokerHosts hosts = new ZkHosts("node1.example.com:2181");
    SpoutConfig spoutConfig = new SpoutConfig(hosts, "mytopic", "", UUID.randomUUID().toString());
    spoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());
    KafkaSpout kafkaSpout = new KafkaSpout(spoutConfig);

    builder.setSpout("sentences", kafkaSpout, 4);

    builder.setBolt("split", new SplitSentence(), 2).shuffleGrouping("sentences");
    builder.setBolt("count", new WordCount(), 2).fieldsGrouping("split", new Fields("word"));

    // kafka output bolt
    Properties props = new Properties();
    props.put("metadata.broker.list", "node1.example.com:6667");
    props.put("serializer.class", "kafka.serializer.StringEncoder");
    conf.put(KafkaBolt.KAFKA_BROKER_PROPERTIES, props);
    KafkaBolt bolt = new KafkaBolt()
          .withTopicSelector(new DefaultTopicSelector("mytopic2"))
          .withTupleToKafkaMapper(new FieldNameBasedTupleToKafkaMapper());
    builder.setBolt("forwardToKafka", bolt , 4).shuffleGrouping("count");

    conf.setDebug(true);

    if (args != null && args.length > 0) {
      conf.setNumWorkers(3);

      StormSubmitter.submitTopologyWithProgressBar(args[0], conf, builder.createTopology());
    }
    else {
      conf.setMaxTaskParallelism(3);

      LocalCluster cluster = new LocalCluster();
      cluster.submitTopology("word-count", conf, builder.createTopology());

      Thread.sleep(10000);

      cluster.shutdown();
    }
  }
}
