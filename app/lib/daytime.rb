# RSPEC_TBD

class Time
  def self.sun(date=nil)
    if !date
      date = Date.today
    end
    date = date.to_datetime
    SunRiseSet.new(date, ENV['latitude'].to_f, ENV['longitude'].to_f)
  end
  def self.sunrise(date=nil)
    sun(date).sunrise.to_time
  end
  def self.sunset(date=nil)
    sun(date).sunset.to_time
  end
  def daytime
    Daytime.at( self.to_i - Date.today.to_time.to_i )
  end
end

# class Date
#   def self.next_wday(day)
#     wday=["mon","tue","wed","thu","fri","sat","sun"]
#     date  = Date.parse(wday[day])
#     delta = date > Date.today ? 0 : 7
#     date + delta
#   end
# end



class Daytime < Time

  def self.now
    Time.now.daytime.utc
  end

  def self.parse(value)
    if value.is_a? String
      if /\D/ =~ value
        return Daytime.at(Time.parse(value+" UTC", Time.at(0) ).to_i)
      else
        return Daytime.at(value.to_i)
      end
    else
      return Daytime.at(value)
    end
  end

  def to_s
    if self.sec > 0
      self.strftime("%H:%M:%S")
    else
      self.strftime("%H:%M")
    end
  end

  def today
    Time.at( Date.today.to_time.to_i + self.to_i )
  end

  def tomorrow
    Time.at( Date.today.next_day.to_time.to_i + self.to_i )
  end

  def to_time(date=nil)
    if !date then date = Date.today end
    Time.at( self.to_i + date.to_time.to_i )
  end

end

class Duration < Fixnum
  def self.parse(value)
    if value.is_a? String
      if /\D/ =~ value
        value += " UTC"    # avoid time zone offset
        Time.parse(value, Time.at(0) ).to_i
      else
        value.to_i
      end
    else
      value
    end
  end
end

class Day
  def self.parse(data)
   if data.is_a? String
      if /\D/ =~ data
#        puts "data: #{data}"   # DBG
        self.days(Date.parse(data))
      else
        data.to_i
      end
    else
      data
    end
  end
end

class DayInWeek < Day
  def self.parse(data)   # TBD: verify method
    super % 7
  end

  def self.days(date)
    date.wday
  end
end


class DayInMonth < Day
  def self.parse(data)   # TBD: verify method
    day = super
    if day.between?(1,31)
      day
    else
      nil
    end
  end

  def self.days(date)
    date.mday
  end
end

class DayInYear < Day
  def self.days(date)   # TBD: verify method
    date.yday
  end
end
