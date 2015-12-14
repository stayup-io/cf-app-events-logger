require 'event_converter'

RSpec.describe 'EventConverter' do
	
	let(:sample_event) do
		{
	    :guid => "507d2212-dd8c-4bef-b6cc-event_guid",
	    :type => "the_type",
	    :actor => "the_actor",
	    :actor_type => "the_actor_type",
	    :actee => "the_actee",
	    :actee_type => "the actee_type",
	    :timestamp => Time.now,
	    :metadata => '{ "key": "some extra metadata value"}',
	    :space_guid => "507d2212-dd8c-4bef-b6cc-spaceguid",
	    :organization_guid => "507d2212-dd8c-4bef-b6cc-org_guid"
	  } 
	end

	let(:converted_event) do
		ec = EventConverter.new 
		ec.convert(sample_event)
	end

	it "should have the correct :event_type" do
		expect(converted_event[:event_type]).to eq("AppEvent")
	end
	it "should be 2" do
		expect(true).to be(true)
	end
	it "should be 3" do
		expect(true).to be(true)
	end
end

