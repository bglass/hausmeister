# RSPEC_TBD

require 'thread'


class Schedule

  def initialize
    @@agenda = []
  end

  def waiting_period
    w = @@agenda[0].next - Time.now
    if w > 0
      w
    else
      0
    end
  end

  def self.add(rule)      # agenda is always sorted. insert at position
    if @@agenda.length == 0
      @@agenda = *rule
    else
      ptr = @@agenda.find_index { |r| r.next > rule.next }
      if ptr
        #      printf "l %d i %d\n", @@agenda.length, ptr   # DBG
        @@agenda.insert(ptr, rule)
      else
        @@agenda << rule
      end
    end
  end

  def fetch
#    printf "Sleeping %.1f s\n", waiting_period
    sleep waiting_period
    return @@agenda.shift
  end

  def event_handler    #(Thread 1)
    if @@agenda.length > 0
      puts "Schedule handler started."
      loop do
        rule = fetch
        rule.delegate
        rule.update!
        Schedule.add(rule)
      end
    else
      puts "Unfortunately, there are no rules for the schedule handler."
    end
  end
end


class House
  attr_reader :lattitude, :longitude

  def initialize(location)
    ( @lattitude, @longitude ) = location.split(',')
  end
end
