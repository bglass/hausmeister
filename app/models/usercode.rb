# RSPEC_TBD

class Usercode

  def ga_known?(arg)
    @ga_names.include? arg
  end


  def ga_set(gname,value)
    #TBD
    puts "Setting #{gname} to #{value}."
  end

  def ga_get(gname)
    #TBD
    puts "Getting #{gname}."
  end

  def ga_obj(gname)
    #TBD
    puts "Passing #{gname} object."
  end

  def usercode_preprocess!(code)
    symbol = ":"

    methods = "(process)"     # methods where ga is expected as object

    gastring = '('+symbol+'([\w\d]+)|<([\w\d\s\/]+)>)'
    reg_set  = /#{gastring}\s*=/
    reg_get  = /#{gastring}/
    reg_obj  = /[:<]([\w\d\s\/]+)>*/

    identifier = '[\w\d:<>\s]+'
    margs = /#{methods}\s*\((#{identifier}(,#{identifier})*)\)/

    code.gsub!(margs) do |m1|
      mname     = $1
      argstring = $2
      subst = argstring.gsub(reg_obj) do |m2|
        ga = $1
        ga_known?(ga) ? "self.ga_obj('#{ga}')" : m2
      end
      "#{mname}(#{subst})"
    end

    code.gsub!(reg_set) do |m|
      ga_known?($2) ? "self.ga_set '#{$2}'," : m
    end

    code.gsub!(reg_get) do |m|
      ga_known?($2) ? "self.ga_get('#{$2}')" : m
    end

    code
  end

  def initialize
    @ga_names = Unit.group_address_names
    fname = Dir.glob("local/logic/**/*.rb")

    fname.each do |fn|
      puts Dir.pwd+'/'+fn
      code = File.read(fn)
      usercode_preprocess!(code)
      instance_eval code, fn
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
