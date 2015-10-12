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
  }.to_s
end

def get_all_events_as_strings(events)
  output = []
  last_timestamp = DateTime.parse events[-1].timestamp
  events.each do |event|
    output << event_to_string(event)
  end
  [output, last_timestamp]
end

def get_events(c, since)
  if since.nil?
    c.events
  else
    []
  end
end

#Loop every x min
events = get_events(client, nil)
output, last_timestamp = get_all_events_as_strings(events)
puts output
