# Kredis

Kredis (Keyed Redis) encapsulates higher-level types and data structures around a single key, so you can interact with them as coherent objects rather than isolated procedural commands. These higher-level structures can be configured as attributes within Active Models and Active Records using a declarative DSL.

Kredis is configured using env-aware yaml files, using `Rails.application.config_for`, so you can locate the data structures on separate redis instances, if you've reached a scale where a single shared instance is no longer sufficient.

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
list << "hello world!"
[ "hello world!" ] == list.elements

integer_list = Kredis.list "myintegerlist", typed: :integer
integer_list.append([ 1, 2, 3 ])        # => LPUSH myintegerlist "1" "2" "3"
integer_list << 4                       # => LPUSH myintegerlist "4"
[ 1, 2, 3, 4 ] == integer_list.elements # LRANGE 0 -1

unique_list = Kredis.unique_list "myuniquelist"
unique_list.append(%w[ 2 3 4 ])
unique_list.prepend(%w[ 1 2 3 4 ])
unique_list.append([])
unique_list << "5"
unique_list.remove(3)
[ "1", "2", "4", "5" ] == unique_list.elements

set = Kredis.set "myset", typed: :datetime
set.add(DateTime.tomorrow, DateTime.yesterday)            # => SADD myset "2021-02-03 00:00:00 +0100" "2021-02-01 00:00:00 +0100"
set << DateTime.tomorrow                                  # => SADD myset "2021-02-03 00:00:00 +0100"
2 == set.size                                             # => SCARD myset
[ DateTime.tomorrow, DateTime.yesterday ] == set.elements # => SMEMBERS myset

head_count = Kredis.counter "headcount"
0 == head_count.value              # => GET "headcount"
head_count.increment
head_count.increment
head_count.decrement
1 == head_count.value              # => GET "headcount"

counter = Kredis.counter "mycounter", expires_in: 15.minutes
counter.increment by: 2         # => SETEX "mycounter" 900 0 + INCR "mycounter" 2
2 == counter.value              # => GET "mycounter"
travel 16.minutes
0 == counter.value              # => GET "mycounter"

enum = Kredis.enum "myenum", values: %w[ one two three ], default: "one"
"one" == enum.value
true == enum.one?
enum.value = "two"
"two" == enum.value
enum.value = "four"
"two" == enum.value
enum.reset
"one" == enum.value

slots = Kredis.slots "myslots", available: 3
true == slots.available?
slots.reserve
true == slots.available?
slots.reserve
true == slots.available?
slots.reserve
true == slots.available?
slots.reserve
false == slots.available?
slots.release
true == slots.available?
slots.reset

flag = Kredis.flag "myflag"
false == flag.marked?
flag.mark
true == flag.marked?
flag.remove
false == flag.marked?

flag.mark(expires_in: 1.second)
true == flag.marked?
sleep 0.5.seconds
true == flag.marked?
sleep 0.6.seconds
false == flag.marked?
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
person.names.append "David", "Heinemeier", "Hansson" # => SADD person:5:names "David" "Heinemeier" "Hansson"
true == person.morning.bright?
person.morning.value = "blue"
true == person.morning.blue?
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

Additional configurations can be added under `config/redis/*.yml` and referenced when a type is created.


## License

Kredis is released under the [MIT License](https://opensource.org/licenses/MIT).
