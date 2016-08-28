module RubyKafkaMn
  class Consumer
    Consumer = org.apache.kafka.clients.consumer.Consumer
    ConsumerConfig = org.apache.kafka.clients.consumer.ConsumerConfig;
    KafkaConsumer = org.apache.kafka.clients.consumer.KafkaConsumer;
    StringDeserializer = org.apache.kafka.common.serialization.StringDeserializer
    OffsetAndMetadata = org.apache.kafka.clients.consumer.OffsetAndMetadata;
    TopicPartition = org.apache.kafka.common.TopicPartition;
    WakeupException = org.apache.kafka.common.errors.WakeupException;

    MAX_VALUE = java.lang.Long::MAX_VALUE

    def initialize(topic, group_id, kafkas="localhost:9092")
      @topic = topic
      @consumer = KafkaConsumer.new(build_properties(group_id, kafkas))
    end

    # block on data from specified kafka topic, yield each message we get
    def consume
      # for event sourcing, you'd want to manually subscribe to all partitions
      # this will allow the client to balance across group members
      @consumer.subscribe([@topic]);
      while true
        partition_offsets = {}
        @consumer.poll(MAX_VALUE).each do |record|
          # just handle the record synchronously for simplicity's sake
          # you would probably want to distribute this across a worker pool for e.g. stream processing, async APIs, etc.
          yield(record.key, JSON.parse(record.value), record.partition, record.offset)
          # keep track of the offsets we've handled
          partition_offsets[record.partition] = record.offset if partition_offsets[record.partition].to_i < record.offset
        end

        # commit the max offsets we found for each partition
        # note that for event sourcing you don't want to commit offsets ever (since you want all the data every time)
        # this might be unnecessarily complicated since it basically does the same thing as
        #   @consumer.commitSync
        # but it's an example of how fancy you can get if you want fine-grained control
        # and/or detailed metadata about what you have and haven't processed
        partition_offsets.each do |partition, offset|
          @consumer.commitSync({TopicPartition.new(@topic, partition) => OffsetAndMetadata.new(offset+1)})
        end
      end
    rescue => e
      puts "something bad happened: #{e.message}" # lol idk
      raise
    ensure
      @consumer.close
    end

    private

    def build_properties(group_id, kafkas)
      props = java.util.Properties.new
      # the client will automatically commit offsets periodically unless we tell it not to, which we are here
      # this provides us with at-least-one delivery semantics
      props.put(ConsumerConfig::ENABLE_AUTO_COMMIT_CONFIG, "false");
      props.put(ConsumerConfig::GROUP_ID_CONFIG, group_id)
      props.put(ConsumerConfig::BOOTSTRAP_SERVERS_CONFIG, kafkas)
      props.put(ConsumerConfig::KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.java_class)
      props.put(ConsumerConfig::VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.java_class)
      props
    end
  end
end