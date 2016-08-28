#ruby + kafka = <3

Here's some code to show you how to process data streams from Apache Kafka using JRuby.

# running examples
* start zookeeper (port 2181)
* start kafka (at least one on port 9092, or more if you want)
* have appropriate JRuby (see `.ruby-version`)
* `bundle install`
* `jbundle install`
* run the producer: `bin/pitch_publisher`
* run the consumer: `bin/last_pitch_consumer`
* run another consumer `bin/scoring_consumer`



what we are going to talk about
  what is kafka
  how would you use it
  ruby examples
  future work!
what is kafka
  history
  explain kafka and zookeeper
  maybe some diagrams from BDT pres
  compare to redis, jms, zeromq, rabbitmq, etc.
ways to interact with kafka
  librdkafka
  Jaav
  CLI (uses Java)
things you can do
  stream processing, pubsub
    designed for high throughput and
  job queuing/async APIs
    consumer groups mean this can scale nicely without load balancers etc.
  batch jobs (!!)
    stuff gets stored on filesystem so you can wake up and pull it all down whenever
  event sourcing
    log compaction
catch 22s!
  managing zookeeper kind of sucks
  still a WIP: don't use rando ruby kafka stuff from github if it's not based on an official client

future work
  confluent platform: schema validation, REST proxy, etc.
  frameworks etc. (kafka streams)


kafka vs redis
redis is an in-memory DB with some persistence features
redis pubsub doesn't store per-consumer group offsets, so everyone gets everything



this can be part of core app infrastructure


links
http://www.confluent.io/blog********