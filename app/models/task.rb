# RSPEC_TBD

require 'thread'

class Task

  def initialize
    @@code    = []
    @@label   = []         # for debug and decoration only
    @@time    = []         # for debug and decoration only
    @@mutex   = Mutex.new
    @@ready   = ConditionVariable.new
  end

  def self.add(code, time = nil, label = nil )

    @@mutex.synchronize do
      @@code  << code
      @@label << label
      @@time  << time
      @@ready.signal
    end
  end

  def fetch
    @@mutex.synchronize do
      while @@code.length < 1
        @@ready.wait(@@mutex)
      end
      printf "new Task: %10s Jitter: %+f\n", @@label.shift, Time.now-@@time.shift
      return @@code.shift
    end
  end

  def task_handler        #(Thread 2)
    puts "Task Handler started."
    loop do
      fetch.call
    end
  end
end
