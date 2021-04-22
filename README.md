# Kredis

Kredis (Keyed Redis) encapsulates higher-level types and data structures around a single key, so you can interact with them as coherent objects rather than isolated procedural commands. These higher-level structures can be configured as attributes within Active Models and Active Records using a declarative DSL.

Kredis is configured using env-aware YAML files, using `Rails.application.config_for`, so you can locate the data structures on separate Redis instances, if you've reached a scale where a single shared instance is no longer sufficient.

Kredis provides namespacing support for keys such that you can safely run parallel testing against the data structures without different tests trampling each others data.


## Examples

Kredis provides typed scalars for strings, integers, decimals, floats, booleans, datetimes, and JSON hashes:

```ruby
string = Kredis.string "mystring"
string.value = "hello world!"  # => SET mystring "hello world"
"hello world!" == string.value # => GET mystring

integer = Kredis.integer "myinteger"
integer.value = 5  # => SET myinteger "5"
5 == integer.value # => GET myinteger

json = Kredis.json "myjson"
json.value = { "one" => 1, "two" => "2" }  # => SET myjson "{\"one\":1,\"two\":\"2\"}"
{ "one" => 1, "two" => "2" } == json.value  # => GET myjson
```

There are data structures for counters, enums, flags, lists, unique lists, sets, and slots:

```ruby
list = Kredis.list "mylist"
list << "hello world!"               # => RPUSH mylist "hello world!"
[ "hello world!" ] == list.elements  # => LRANGE mylist 0, -1

integer_list = Kredis.list "myintegerlist", typed: :integer
integer_list.append([ 1, 2, 3 ])        # => RPUSH myintegerlist "1" "2" "3"
integer_list << 4                       # => RPUSH myintegerlist "4"
[ 1, 2, 3, 4 ] == integer_list.elements # => LRANGE myintegerlist 0 -1

unique_list = Kredis.unique_list "myuniquelist"
unique_list.append(%w[ 2 3 4 ])                # => LREM myuniquelist 0, "2" + LREM myuniquelist 0, "3" + LREM myuniquelist 0, "4"  + RPUSH myuniquelist "2", "3", "4"
unique_list.prepend(%w[ 1 2 3 4 ])             # => LREM myuniquelist 0, "1"  + LREM myuniquelist 0, "2" + LREM myuniquelist 0, "3" + LREM myuniquelist 0, "4"  + LPUSH myuniquelist "1", "2", "3", "4"
unique_list.append([])
unique_list << "5"                             # => LREM myuniquelist 0, "5" + RPUSH myuniquelist "5"
unique_list.remove(3)                          # => LREM myuniquelist 0, "3"
[ "4", "2", "1", "5" ] == unique_list.elements # => LRANGE myuniquelist 0, -1

set = Kredis.set "myset", typed: :datetime
set.add(DateTime.tomorrow, DateTime.yesterday)           # => SADD myset "2021-02-03 00:00:00 +0100" "2021-02-01 00:00:00 +0100"
set << DateTime.tomorrow                                 # => SADD myset "2021-02-03 00:00:00 +0100"
2 == set.size                                            # => SCARD myset
[ DateTime.tomorrow, DateTime.yesterday ] == set.members # => SMEMBERS myset

head_count = Kredis.counter "headcount"
0 == head_count.value              # => GET "headcount"
head_count.increment               # => SET headcount 0 NX + INCRBY headcount 1
head_count.increment               # => SET headcount 0 NX + INCRBY headcount 1
head_count.decrement               # => SET headcount 0 NX + DECRBY headcount 1
1 == head_count.value              # => GET "headcount"

counter = Kredis.counter "mycounter", expires_in: 5.seconds
counter.increment by: 2         # => SET mycounter 0 EX 5 NX + INCRBY "mycounter" 2
2 == counter.value              # => GET "mycounter"
sleep 6.seconds
0 == counter.value              # => GET "mycounter"

cycle = Kredis.cycle "mycycle", values: %i[ one two three ]
:one == cycle.value             # => GET mycycle
cycle.next                      # => GET mycycle + SET mycycle 1
:two == cycle.value             # => GET mycycle
cycle.next                      # => GET mycycle + SET mycycle 2
:three == cycle.value           # => GET mycycle
cycle.next                      # => GET mycycle + SET mycycle 0
:one == cycle.value             # => GET mycycle

enum = Kredis.enum "myenum", values: %w[ one two three ], default: "one"
"one" == enum.value             # => GET myenum  
true == enum.one?               # => GET myenum
enum.value = "two"              # => SET myenum "two"
"two" == enum.value             # => GET myenum
enum.value = "four"
"two" == enum.value             # => GET myenum
enum.reset                      # => DEL myenum
"one" == enum.value             # => GET myenum  

slots = Kredis.slots "myslots", available: 3
true == slots.available?        # => GET myslots
slots.reserve                   # => INCR myslots
true == slots.available?        # => GET myslots
slots.reserve                   # => INCR myslots     
true == slots.available?        # => GET myslots
slots.reserve                   # => INCR myslots
false == slots.available?       # => GET myslots
slots.reserve                   # => INCR myslots + DECR myslots  
false == slots.available?       # => GET myslots
slots.release                   # => DECR myslots
true == slots.available?        # => GET myslots
slots.reset                     # => DEL myslots

flag = Kredis.flag "myflag"
false == flag.marked?           # => EXISTS myflag
flag.mark                       # => SET myflag 1
true == flag.marked?            # => EXISTS myflag
flag.remove                     # => DEL myflag  
false == flag.marked?           # => EXISTS myflag

flag.mark(expires_in: 1.second) #=> SET myflag 1 EX 1
true == flag.marked?            #=> EXISTS myflag
sleep 0.5.seconds
true == flag.marked?            #=> EXISTS myflag
sleep 0.6.seconds
false == flag.marked?           #=> EXISTS myflag
```

And using structures on a different than the default `shared` redis instance, relying on `config/redis/secondary.yml`:

```ruby
one_string = Kredis.string "mystring"
two_string = Kredis.string "mystring", config: :secondary

one_string.value = "just on shared"
two_string.value != one_string.value
```

You can use all these structures in models:

```ruby
class Person < ApplicationRecord
  kredis_list :names
  kredis_list :names_with_custom_key, key: ->(p) { "person:#{p.id}:names_customized" }
  kredis_unique_list :skills, limit: 2
  kredis_enum :morning, values: %w[ bright blue black ], default: "bright"
end

person = Person.find(5)
person.names.append "David", "Heinemeier", "Hansson" # => RPUSH people:5:names "David" "Heinemeier" "Hansson"
true == person.morning.bright?                       # => GET people:1:morning
person.morning.value = "blue"                        # => SET people:1:morning
true == person.morning.blue?                         # => GET people:1:morning
```


## Installation

1. Add the `kredis` gem to your Gemfile: `gem 'kredis'`
2. Run `./bin/bundle install`
3. Add a default configuration under `config/redis/shared.yml`

A default configuration can look like this for `config/redis/shared.yml`:

```yaml
production: &production
  host: <%= ENV.fetch("REDIS_SHARED_HOST", "127.0.0.1") %>
  port: <%= ENV.fetch("REDIS_SHARED_PORT", "6379") %>
  timeout: 1

development: &development
  host: <%= ENV.fetch("REDIS_SHARED_HOST", "127.0.0.1") %>
  port: <%= ENV.fetch("REDIS_SHARED_PORT", "6379") %>
  timeout: 1

test:
  <<: *development
```

Additional configurations can be added under `config/redis/*.yml` and referenced when a type is created, e.g. `Kredis.string("mystring", config: :strings)` would lookup `config/redis/strings.yml`. Under the hood `Kredis.configured_for` is called which'll pass the configuration on to `Redis.new`.

### Setting SSL options on Redis Connections

If you need to connect to Redis with SSL, the recommended approach is to set your Redis instance manually by adding an entry to the `Kredis::Connections.connections` hash. Below an example showing how to connect to Redis using Client Authentication:

```ruby
Kredis::Connections.connections[:shared] = Redis.new(
  url: ENV['REDIS_URL'],
  ssl_params: {
    cert_store: OpenSSL::X509::Store.new.tap { |store|
      store.add_file(Rails.root.join('config', 'ca_cert.pem').to_s)
    },

    cert: OpenSSL::X509::Certificate.new(File.read(
      Rails.root.join('config', 'client.crt')
    )),

    key: OpenSSL::PKey::RSA.new(
      Rails.application.credentials.redis[:client_key]
    ),

    verify_mode: OpenSSL::SSL::VERIFY_PEER
  }
)
```

The above code could be added to either `config/environments/production.rb` or an initializer. Please ensure that your client private key, if used, is stored your credentials file or another secure location.

## License

Kredis is released under the [MIT License](https://opensource.org/licenses/MIT).
