#!/usr/bin/env python
from operator import add
from pyspark import SparkContext


if __name__ == "__main__":
    sc = SparkContext(appName="WordCount")
    lines = sc.textFile("hdfs:///user/vagrant/constitution.txt")
    counts = lines.flatMap(lambda x: x.split(' ')) \
                  .map(lambda x: (x, 1)) \
                  .reduceByKey(add)
    output = counts.collect()
    for (word, count) in output:
        print str(word) +": "+ str(count);

    sc.stop()
