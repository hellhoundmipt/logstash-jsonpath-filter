# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# Filter plugin that transforms json to jsonpath (creates field for each of paths)
class LogStash::Filters::JSONPath < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   jsonpath {
  #     field => "string_containing_json"
  #     prefix => "prefix"
  #   }
  # }
  #
  config_name "jsonpath"

  # Field containing json (must be a string, not a hash)
  config :field, :validate => :string, :required => true
  # Prefix for new fields
  config :prefix, :validate => :string

  def deep_traverse(hash)
    stack = hash.map { |k, v| [[@prefix, k], v] }
    until stack.empty?
      key, value = stack.pop
      if value.is_a? Hash
        value.each { |k, v| stack.push [key.dup << k, v] }
      elsif value.is_a? Array
        value.each { |v| stack.push [key, v] }
      else
        yield(key.join('.'), value)
      end
    end
  end


  public
  def register
    @prefix = field unless @prefix
  end # def register

  public
  def filter(event)
    require 'json'
    hash = {}
    begin
      json = JSON.parse(event.get(@field))
      deep_traverse(json) do |path, value|
        if hash.has_key?(path)
          hash[path] << value
        else
          hash[path] = [value]
        end
      end
    rescue
      @logger.warn("Could not parse json")
    end
    hash.each do |k, v|
      event.set(k, v)
    end
    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::JSONPath
