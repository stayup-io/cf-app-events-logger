# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

guard :rspec, cmd: "bundle exec rspec spec/*-spec.rb" do
  # watch /lib/ files
  watch(%r{^lib/(.+).rb$}) do |m|
    "spec/#{m[1]}_spec.rb"
  end
 
  # watch /spec/ files
  watch(%r{^spec/(.+).rb$}) do |m|
    "spec/#{m[1]}.rb"
  end

end
