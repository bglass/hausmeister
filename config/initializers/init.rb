Database.connect
Ets.create_subclasses
Ets.initialize_tables
Relation.create_methods

schedule = Schedule.new
task     = Task.new
usercode = Usercode.new

knx      = KNX.new



ehandle = Thread.new {  schedule.event_handler  }
khandle = Thread.new {  knx.event_handler       }
thandle = Thread.new {  task.task_handler       }


binding.pry
