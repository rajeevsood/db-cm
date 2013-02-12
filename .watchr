require 'rubygems'
#require 'growl'

def run_specs
  puts "Running specs..."
  result = `rspec spec`
  result.split("\n").each do |msg|
    puts msg
  end
    
  if result == 'true' || result.match(/\s0\s(errors|failures)/)

#    growl result, 0
  else
#    growl result, 4
  end
end

#def initialize_growl
#  @growl = Growl.new "Watchr"
#  @growl.register({:notifications => [{:name => "Watchr", :enabled => true}]})
#end

def growl(msg, priority)
Growl.notify msg, :title => "Test Results", :priority => priority
#  @growl.notify({
#                  :name => "Watchr",
#                  :title => "Test Results",
#                  :text => msg
#                })
end

puts "Greetings. I'll run all specs whenever you save a source file."
#initialize_growl

watch('spec/(.*)\.rb') {|md| run_specs}
watch('lib/(.*)\.rb') {|md| run_specs}

