class EventConverter
  def convert(event)
	  data = {
	    :event_type => "AppEvent",
	    :guid => event.guid,
	    :type => event.type,
	    :actor => event.actor,
	    :actor_type => event.actor_type,
	    :actee => event.actee,
	    :actee_type => event.actee_type,
	    :timestamp => event.timestamp,
	    :metadata => event.metadata,
	    :space_guid => event.space_guid,
	    :organization_guid => event.organization_guid
	  }
	  #data.merge(metadata(data))
	  data
  end
end