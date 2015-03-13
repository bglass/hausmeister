puts "Connecting Database..."
Database.connect

puts "Createing Ets Subclasses..."
Ets.create_subclasses

puts "Initializing LU Tables..."
Ets.initialize_tables

puts "Creating cross reference methods..."
Relation.create_methods

puts "Initializing Schedule..."
schedule = Schedule.new

puts "Initializing Task..."
task     = Task.new

puts "Reading Usercode..."
usercode = Usercode.new

puts "Connecting KNX..."
knx = KNX.open

# ehandle = Thread.new {  schedule.event_handler  }
# khandle = Thread.new {  knx.event_handler       }   if knx
# thandle = Thread.new {  task.task_handler       }


# binding.pry
