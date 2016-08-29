#ruby + kafka = <3

From the "Data Processing with Ruby and Apache Kafka" ruby.mn August 2016 presentation.

# running examples
* start zookeeper (port 2181)
* start kafka (at least one on port 9092, or more if you want)
* have appropriate JRuby (see `.ruby-version`)
* `bundle install`
* `jbundle install`
* run the producer: `bin/pitch_publisher`
* run the event sourcing consumer:  [bin/last_pitch_consumer](bin/last_pitch_consumer)
* run an announcer consumer: [bin/announcer_consumer](bin/announcer_consumer)
* run some more announcer consumers if you want
* watch stdout for application stuff, and java_stuff.log to see what is going on with the kafka client

# Talk Stuff

## What is this all about?
* What's a Kafka?
    * How does it work?
    * How do you use it?
        * it's free, [go download it](https://kafka.apache.org/)
* How can you make it work with Ruby?
    * it can be kind of complicated, maybe this project will help
    * demo!
* What's next?

## Kafka and stream processing
* What's a Kafka?
    * https://kafka.apache.org/
    * a distributed commit log-based messaging system...???
    * pretty good paper summarizing architecture: http://research.microsoft.com/en-us/um/people/srikanth/netdb11/netdb11papers/netdb11-final12.pdf

* [Architecture](images/kafka_example.jpg):
    * broker: kafka servers, messages go in, and are persisted for going out
    * message: some bytes, could be anything (key and value)
    * topic: a log of messages intended for consumption by one of more consumer groups
        * includes configuration around data retention, number of partitions, etc.
    * partition: part of a topic (broker can host many partitions)
    * offset: sequential message id (really just a byte position within a partiion, monotonically increasing) 
    * leader: the node of record for a given topic partition
    * replica: a node that nas a copy of a partition owned by another node
    * in-sync replica: a node whose replica is up-to-date
    * producer: a program somewhere that publishes messages to a topic
        * has configurable policies around failures, what a successful write is, etc.
    * consumer: a program that receives messages and maybe commits offsets
    * consumer group: multiple consumers that act as a logical group (i.e. they share offsets and balance partitions) 
    
## Use cases
* stream processing/pubsub
    * analytics
    * monitoring metrics
* async APIs/job queueing
    * consumer groups meke it pretty easy to scale up in the right place if you need to
* batch processing
    * logs are stored on filesystem, you can wake up and pull it all down whenever you want
* [event sourcing](http://www.martinfowler.com/eaaDev/EventSourcing.html)
    * log compaction makes this an interesting option for storing key-value relationships, esp if you need it in-memory
* understanding how databases and commit logs are related
    * your database almost definitely depends on this abstraction to work and replicate [1]
    * log is a fundamental data structure from which you can create tables or derivations
* The enterprise service bus is dead, long live the ESB
    * really helped me understand SOA/microservices in a way that I didn't before
        * [microservices past](images/soa_fail.jpg)
        * [microservices future](images/soa_win.jpg)
## Ways to integrate
* Java client
* librdkafka
* REST proxy (confluent.io)
* clients built on librdkafka (python, ruby maybe soon?)
* something some rando wrote on github (not recommended...yet)
    
# Other options    
* what's unique about Kafka vs. e.g.
    * ActiveMQ/JMS whatever
        * has some other enterprisey features (XA transactions)
    * ZeroMQ
        * has no concept of topics and partitions, probably harder to scale up
        * probably faster, simpler for ops
        * kind of low-level, probably more complicated to develop
    * RabbitMQ
        * probably has the biggest overlap in terms of use cases
        * broker keeps track of offsets, not consumer
        * routing can be much fancier
    * Redis
        * an in-memory DB with persistence/HA kind of bolted on
    * most stuff
        * persistence + consumer group abstraction is really nice
            * consumers going offline or operating as batch jobs are as easy to accommodate as the happy path of real-time processors 

## demos
* last_pitch_consumer: an event sourcing thing, kind of
* announcer_consumer: provide play-by-play for every game at once
    *   add/remove consumers

## What is kind of janky about it?
* Built as a distributed system from the ground up, latency can cause bigger problems than in other cases
    * makes ops component more complicated, too
* It's a good idea to think about cluster sizing/topic parameters up front
    * there are a ton of levers and not a lot of best practices
* API is just now becoming stable, lots of outdated info/clients
    * non-Java situation is improving
* logs are a low-level abstraction, just one piece of the puzzle when it comes to handling stream data [2]

## Next steps
* someone write a stable MRI client (librdkafka + FFI plz)
* write stuff with better ergonomics for the various use cases
* Kafka Streams: might cater to Ruby tastes better than previous stream data frameworks

## AMA
* ?????

## Notes
[1] Lots of Jay Kreps writings on table-log duality. Here's one: https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying  
[2] Confluent Platform combines Kafka with a schema registry and some other tools in an attempt to create amore Rails-esque curated set of technologies. http://www.confluent.io/