require 'cfoundry'
require 'json'
require 'rufus-scheduler'

cf_api = "https://api.10.244.0.34.xip.io"
cf_user = "admin"
cf_password = "admin"

client = CFoundry::Client.get(cf_api)
client.login({:username => cf_user, :password => cf_password})

def event_to_string(e)
  {
    :guid => e.guid,
    :type => e.type,
    :actor => e.actor,
    :actor_type => e.actor_type,
    :actee => e.actee,
    :actee_type => e.actee_type,
    :timestamp => e.timestamp,
    :metadata => e.metadata,
    :space_guid => e.space_guid,
    :organization_guid => e.organization_guid
  }.to_json
end

def get_all_events_as_strings(events)
  output = []
  last_timestamp = nil
  if events.count != 0
    last_timestamp = DateTime.parse events[-1].timestamp
    last_guid = events[-1].guid
    events.each do |event|
      output << event_to_string(event)
    end
  end
  [output, last_timestamp, last_guid]
end

def create_query(timestamp)
  qv = CFoundry::V2::ModelMagic::QueryValue.new(comparator: '>', value: timestamp)
  {query: {timestamp: qv}}
end

def get_events(c, timestamp)
  query = create_query(timestamp)
  c.events(query)
end


# Last hours worth of events.
timestamp = Time.now - 60*60
#Loop every x min
while true
  events = get_events(client, timestamp)
  output, last_timestamp, last_guid = get_all_events_as_strings(events)
  if output
    output.each do |o|
      if not o.include? last_guid
        puts o
      end
    end
  end
  if not last_timestamp.nil?
    timestamp = last_timestamp
  end
  sleep 1
end
