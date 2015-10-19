require 'cfoundry'
require 'json'
require 'set'
require 'moneta'
require 'rufus-scheduler'

cf_api = ENV['CF_API']
cf_user = ENV['CF_USER']
cf_password = ENV['CF_PASSWORD']
fetch_every = ENV['FETCH_EVERY'] || 10
clear_cache_every = ENV['CLEAR_CACHE_EVERY'] || 300

@client = CFoundry::Client.get(cf_api)
@client.login({:username => cf_user, :password => cf_password})

@cache = Moneta.new(:LRUHash)

def metadata(e)
  org_id = e[:organization_guid]
  org_name = if @cache[org_id] then @cache[org_id] else @cache[org_id] = (@client.organization org_id).name end
  space_id = e[:space_guid]
  space_name = if @cache[space_id] then @cache[space_id] else @cache[space_id] = (@client.space space_id).name end

  actor_name = ""
  actor_id = e[:actor]
  if e[:actor_type] == "app"
    actor_name = if @cache[actor_id] then @cache[actor_id] else @cache[actor_id] = (@client.app actor_id).name end
  elsif e[:actor_type] == "user"
    actor_name = if @cache[actor_id] then @cache[actor_id] else @cache[actor_id] = (@client.user actor_id).email end
  end

  actee_name = ""
  actee_id = e[:actee]
  if e[:actee_type] == "app"
    actee_name = if @cache[actee_id] then @cache[actee_id] else @cache[actee_id] = (@client.app actee_id).name end
  elsif e[:actee_type] == "space"
    actee_name = if @cache[actee_id] then @cache[actee_id] else @cache[actee_id] = (@client.space actee_id).name end
  end

  data = {
    :actor_name => actor_name,
    :actee_name => actee_name,
    :organization_name => org_name,
    :space_name => space_name,
  }

  if e[:actor_type] == "app"
    data[:app_id] = actor_id
    data[:app_name] = if @cache[actor_id] then @cache[actor_id] else @cache[actor_id] = (@client.app actor_id).name end
  elsif e[:actee_type] == "app"
    data[:app_id] = actee_id
    data[:app_name] = if @cache[actee_id] then @cache[actee_id] else @cache[actee_id] = (@client.app actee_id).name end
  end
  data
end

def event_to_hash(e)
  data = {
    :event_type => "AppEvent",
    :guid => e.guid,
    :type => e.type,
    :actor => e.actor,
    :actor_type => e.actor_type,
    :actee => e.actee,
    :actee_type => e.actee_type,
    :actee_type => e.actee_type,
    :timestamp => e.timestamp,
    :metadata => e.metadata,
    :space_guid => e.space_guid,
    :organization_guid => e.organization_guid
  }
  data.merge(metadata(data))
end

def get_all_events_as_strings(events)
  output = []
  last_timestamp = nil
  if events.count != 0
    last_timestamp = DateTime.parse events[-1].timestamp
    events.each do |event|
      output << event_to_hash(event)
    end
  end
  [output, last_timestamp]
end

def create_query(timestamp)
  qv = CFoundry::V2::ModelMagic::QueryValue.new(comparator: '>', value: timestamp)
  {query: {timestamp: qv}}
end

def get_events(c, timestamp)
  query = create_query(timestamp)
  c.events(query)
end

def clear_appname_cache(counter, every, cache)
  if counter % every == 0
    puts "Clearing app name cache"
    cache.clear()
  end
end

scheduler = Rufus::Scheduler.new

# Main loop
scheduler.every "#{clear_cache_every}s" do
  puts "Clearing cache"
  @cache.clear()
end

timestamp = Time.now - 60*60
output_guids = Set.new
scheduler.every "#{fetch_every}s", :first_in => '1s' do
  puts "Fetching events"

  events = get_events(@client, timestamp)
  output, last_timestamp = get_all_events_as_strings(events)

  output.each do |o|
    guid = o[:guid]
    if not output_guids.include? guid
      puts o.to_json
      output_guids << guid
    end
  end
  if not last_timestamp.nil?
    timestamp = last_timestamp
  end
  $stdout.flush
end

scheduler.join
