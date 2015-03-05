# RSPEC_TBD

class Rule

  attr_reader :next

  def initialize(code, data=nil)
    def maxparam()  nil      end

    if data.is_a? TrueClass


      @timing = nil
      @next   = next_time(@timing)
      @switch = data
    else
#      puts "init"   # DBG
#      puts data     # DBG
      @timing = array(data)
      @next, @switch = next_time(@timing)

    end

    if !@switch then @switch = true end

    @code = code

#    puts self.label       # DBG
#    puts @next            # DBG
#    puts "[#{@switch}]"   # DBG
#    puts "==="            # DBG

    if fail_num_parameters then return nil end

    Schedule.add(self)
    printf "Registered rule: %s %s\n", self.label, self.timing_str
  end

  def delegate
    Task.add( @code, @next, label)
  end

  def update!
    @next, @switch = next_time(@timing)
  end



  def timing_str
    if @timing
      @timing.join (' ')
     end
  end


  def fail_num_parameters
    if @timing
      length = @timing.length
    else
      length = 0
    end

    if minparam and length < minparam
      msg_reject_rule("Too few")
    elsif maxparam and length > maxparam
      msg_reject_rule("Too many")
    end
  end


  def msg_reject_rule(reason)
    puts "WARNING: #{reason} timing values for #{label()}:#{@timing}. Rule rejected."
  end

  def array(data)
    if data
      [*data].flatten
    end
  end
end

class Recurrent < Rule       # Rules with one date/time list
  def array(timing)
    super.map! { |time| time_parse(time) }
  end
end

class Periodic < Rule        # Rules with both data and time list

  def array(timing)
    (times, days) = timing

#    puts "Times: #{times}" #DBG
#    puts "Days:  #{days}"  #DBG

    times = super(times).map! { |time| time_parse(time) }
    days  = super(days).map!  { |day|  day_parse(day)   }

#    puts "Times: #{times}" #DBG
#    puts "Days:  #{days}"  #DBG

    return [ times, days ]
  end



  def next_time(timing)
    (times, days) = timing

    if label == "Weekly"
#      binding.pry
    end

    time_index = times.find_index { |time| time > Daytime.now }


    if time_index
      check_xday = xday(Date.today)
    else
      time_index = 0
      check_xday = xday(Date.today.next_day)
    end

    if !nextday = days.find { |day| day >= check_xday }
      nextday = days[0]
    end

    next_date = next_xday(nextday)

    return times[time_index].to_time(next_date), time_index.even?
  end


  def next_xday(nextday)
    step = nextday - xday(Date.today)
    date = Date.today + step
    if step < 0
      inc_period(date)
    else
      date
    end
  end

  def time_parse(data)
    Daytime.parse(data)
  end
end

########################
# User Rules Defitions
#########################

class Propagate < Rule
  def label() "Propagate"  end

  def initialize(code, items)

    @code = code
    @timing = nil
    @next   = Time.now
    @switch = true

    # TODO
    # items.each   { |item|   item.dependants << self }   # hook this rule to its input items

    #code.call    # init should happen somewhere else
  end

  def trigger
    puts label
    Task.add(@code, Time.now, label)
  end
end

#=========================

class Daily < Recurrent
  def label() "Daily"  end
  def minparam()  0    end

  def next_time(timing)
    now = Daytime.now
    if timing.last < now
      return timing.first.tomorrow, true
    else
      ptr = timing.find_index { |time| time > now }
      return timing[ptr].today, ptr.even?     # next_time, switch
    end
  end

  def time_parse(data)
    Daytime.parse(data)
  end
end

#=========================

class Datetimes < Recurrent
  def label() "Datetimes"  end
  def minparam()  1        end


  def next_time(timing)
    now = Time.now
    ptr = timing.find_index { |time| time > now }
    return timing[ptr], ptr.even?     # next_time, switch
  end

  def time_parse(data)
    Time.parse(data)
  end
end

#=========================

class Repeat < Recurrent
  def label() "Repeat" end
  def minparam()  1    end
  def maxparam()  2    end

  def initialize(code, data=nil)
    super
    @t0 = nil
  end

  def next_time(period)

    (t1, t2) = period

    if !t2                        # one argument means length of period /
      t2 = t1 = t1/2              # sum of two arguments is length of period
    end

    if @t0
      if (@toggle)
        @edge += t1
      else
        @edge += t2
      end
    else
      @edge = @t0 = Time.now
      @toggle = false
    end

    @toggle = !@toggle

    return @edge, @toggle
  end

  def time_parse(data)
    Duration.parse(data)
  end

end

#=========================

class Weekly < Periodic
  def label() "Weekly" end
  def minparam()  1    end

  def xday(date)
    date.wday
  end

  def day_parse(data)
    DayInWeek.parse(data)
  end

  def inc_period(date)
    date+7
  end

end

#=========================

class Monthly < Periodic
  def label() "Monthly" end
  def minparam()  1     end


  def xday(date)
    date.mday
  end

  def day_parse(data)
    DayInMonth.parse(data)
  end

  def inc_period(date)
    date >> 1
  end

 end

#=========================

class Yearly < Periodic
  def label() "Yearly" end
  def minparam()  1    end

  def xday(date)
    date.yday
  end

  def day_parse(data)
    DayInYear.parse(data)
  end

  def inc_period(date)
    date >> 12
  end

end

#=========================

class Sunrise < Rule
  def label() "Sunrise" end
  def minparam()  0     end
  def maxparam()  0     end

  def next_time(unused)
    if Time.now > Time.sunrise
      Time.sunrise(Date.today.next_day)
    else
      Time.sunrise
    end
  end

  def array(timing)
    nil
  end
end

#=========================

class Sunset < Rule
  def label() "Sunset" end
  def minparam()  0    end
  def maxparam()  0    end

  def next_time(unused)
    if Time.now > Time.sunset
      Time.sunset(Date.today.next_day)
    else
      Time.sunset
    end
  end
  def array(timing)
    nil
  end
end

#=========================
