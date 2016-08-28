Jars.require_jars_lock!

require "ruby_kafka_mn/version"
require "ruby_kafka_mn/publisher"
require "ruby_kafka_mn/consumer"
require "json"

module RubyKafkaMn
  Properties = java.util.Properties
end