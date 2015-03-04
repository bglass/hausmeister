# RSPEC_TBD

class Usercode


  def initialize
    read
    @item  = {}
    ObjectSpace.each_object(Item).each do |itm|
      @item[itm.name] = itm
    end
  end

  def read
    methods = "(process)"                   # methods expecting objects rather than values:

    itm = "[a-zA-Z]\\w+"


    @usercode = File.read(ENV['userfile']).split(/\r?\n|\r/)
    @usercode.map! do |line|
      if /^\s*\b#{methods}\b/ =~ line
        # group symbol in argument list -> give object
        line.gsub(/#{ENV['group-prefix']}(#{itm})/,'@item["\1"]')
        # group symbol followed by '.' (and presumably a method)
      elsif /#{ENV['group-prefix']}(\w+)\./ =~ line
        line.gsub(/#{ENV['group-prefix']}(#{itm})/,'@item["\1"]')
      else
        # others: use value for assignements
        line.gsub(/#{ENV['group-prefix']}(#{itm})/,'@item["\1"].value')
      end
    end
  end


  def eval
    instance_eval @usercode.join("\n"), ENV['userfile']
#require 'pry' #dbg
#binding.pry   #dbg
end

  def show
    puts @usercode
  end



  #######################################################
  #  item access
  #######################################################

  def self.create_item_access

    puts "Item Access"

    Item.all_names.each do |name|

#      puts "Defining #{name}."   # DBG

      define_method name do
        Item.by_name(name).value
      end

      define_method name+'=' do |value|
        Item.by_name(name).value = value
      end

    end
  end



  #######################################################
  #  the following methods are for the user's code
  #######################################################

  def process (*items)
    Propagate.new( Proc.new, items )
  end
  def on_start
    puts "Starting up..."
    yield
    puts "---"
  end
  def on_exit
    on_exit_code = Proc.new
  end
  def repeat(period)
    Repeat.new(Proc.new, period)
  end
  def oscillate(period)
    Repeat.new(Proc.new,period)
  end
  def daily(timing=nil)
    code = Proc.new
    if timing
      Daily.new(code,timing)
    else
      Sunrise.new(code, true)
      Sunset.new(code, false)
    end
  end
  def datetimes(timing)
    Datetimes.new(Proc.new,timing)
  end
  def nightly
    code = Proc.new
    Sunset.new(code, true)
    Sunrise.new(code, false)
  end
  def weekly(timing,days)
    Weekly.new(Proc.new, [timing,days])
  end
  def monthly(timing,days)
    Monthly.new(Proc.new, [timing,days])
  end
  def yearly(timing,dates)
    Yearly.new(Proc.new, [timing,dates])
  end
  def sunrise
    Sunrise.new(Proc.new)
  end
  def sunset
    Sunset.new(Proc.new)
  end
  def knx_received
    # add to task list
    # forward changes
  end
end
