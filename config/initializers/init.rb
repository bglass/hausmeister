Database.connect
Ets.create_subclasses
Relation.create_methods

schedule = Schedule.new
task     = Task.new
usercode = Usercode.new

# knx      = KNX.new



ehandle = Thread.new {  schedule.event_handler  }
# khandle = Thread.new {  knx.event_handler       }
thandle = Thread.new {  task.task_handler       }


Thread.new do
        binding.pry
  IO.popen('ping drain') do |io|
    io.each do |line|
      websocket :channel do
        send_message(:channel, session['websocket_user'], {data: line})
      end

      # @clients.each do |socket|
        # socket.send line
      # end
    end
  end
end



# binding.pry
