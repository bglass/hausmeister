Database.connect
Ets.create_subclasses
Relation.create_methods

schedule = Schedule.new
task     = Task.new
usercode = Usercode.new

# knx      = KNX.new

binding.pry


ehandle = Thread.new {  schedule.event_handler  }
# khandle = Thread.new {  knx.event_handler       }
thandle = Thread.new {  task.task_handler       }





binding.pry
