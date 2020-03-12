# Logstash JSONPath Filter Plugin

This filter transforms json in a specified field to a set of jsonpaths and places each one in its own field.
### Installation

1. Install jruby and bundler
    ```shell script
    rvm install jruby
    jruby -S gem install bundler
    ```
2. Install dependences
    ```shell script
    jruby -S bundle install
    ```
3. Build ruby gem
    ```shell script
    gem build logstash-jsonpath-filter.gemspec
    ```
4. Install plugin into Logstash
    ```shell script
    bin/logstash-plugin install /my/logstash/plugins/logstash-jsonpath-filter/logstash-jsonpath-filter-0.1.0.gem
    ```
### Usage
Let an event be
```json
{
  "some_other_field": "Some value",
  "field_with_json": "{\"name\": \"Mark\",\"friends\":[{\"name\": \"Leia\"}, {\"name\": \"Han\"}]}"
}
```

Define the filter
```
filter {
  jsonpath {
    field => "field_with_json"
    prefix => "root"
  }
}
```

The result will be

```json
{
  "some_other_field": "Some value",
  "field_with_json": "{\"name\": \"Mark\",\"friends\":[{\"name\": \"Leia\"}, {\"name\": \"Han\"}]}",
  "root.name": ["Mark"],
  "root.friends.name": ["Leia", "Han"]
}
```
