module RubyKafkaMn
  class Publisher
    KafkaProducer = org.apache.kafka.clients.producer.KafkaProducer
    ProducerConfig = org.apache.kafka.clients.producer.ProducerConfig
    ProducerRecord = org.apache.kafka.clients.producer.ProducerRecord
    StringSerializer = org.apache.kafka.common.serialization.StringSerializer;


    class Callback
      java_implements 'org.apache.kafka.clients.producer.Callback'

      java_signature 'void onCompletion(RecordMetadata metadata, Exception exception)'
      def onCompletion(metadata, exception)
        if exception
          puts "uhhh that didn't work: #{exception.message}"
        else
          puts "published message with checksum #{metadata.checksum} to #{metadata.topic} - partition #{metadata.partition} - offset #{metadata.offset}"
        end
      end
    end

    def initialize(kafkas = 'localhost:9092')
      @producer = KafkaProducer.new(build_properties(kafkas))
      @callback = Callback.new
    end

    # async publish that returns a Java Future
    # also supplied a callback that putses some info
    def publish(topic, key, value)
      record = ProducerRecord.new(topic, key, value.to_json)
      @producer.send(record, @callback)
    end

    private

    # tell the client where Kafka is
    # and that the keys and values are all strings
    def build_properties(kafkas)
      props = Properties.new
      props.put(ProducerConfig::BOOTSTRAP_SERVERS_CONFIG, kafkas)
      props.put(ProducerConfig::VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.java_class);
      props.put(ProducerConfig::KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.java_class);
      props.put("acks", "all")
      props
    end
  end
end