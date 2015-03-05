on_start do
  a = 4
  :L001 = 10
  :L101 = 20
end

on_exit do
  :L001.off
  :L101.off
end

process(:L101, :L102) do
  :L104A = :L001 + 1
  :L104B = :L101 + 2
end



#repeat    (period [,enable] ) { code }

repeat([99999])  do
  :L101 = :L101 + 1
end


repeat 20 do
  :L101 = :L101 + 1
end

# oscillate (period [,enable] ) { code }        # = repeat(period/2) and @switch is available

oscillate 7.0 do
end


# daily              {code}         # sunrise to sunset

daily do
end

# nightly            {code}         # sunset to sunrise

nightly do
end

# daily  (time)      {code}

daily("12:00:11") do
end

daily([ [ "00:00:12", "12:10:00" ], [ "13:00:00", "13:10:00" ], [ "14:00:00", "14:10:00" ] ]) do
end

datetimes(["1.1.2015 12:00", "4 May 2015 13:00"]) do
end

weekly(["00:11:00","01:00:00","08:00:00"], [0, 1, 2, 3, 4, 5]) do
end



weekly("13:00:00", [ 0, 1, 6]) do
end
weekly("13:00:00", [ "mon", "Wed", "Sat", "Sun"]) do
end
monthly("14:00:00", [1,15]) do
end
yearly("15:00:00", [1,180]) do
end
yearly("16:00:00", ["Sep 4", "Oct 20", "Nov 22", "Dec 11"]) do
end

sunrise do
end

sunset   do
end

# knx_received do
#  puts @changes
# end






time =  "23:45"                                                                 # at time
time =  [ "09:00", "10:00", "12:00" ]                                           # many times / period
time =  [ [ "12:34", "23:45" ] ]                                                # period
time =  [ [ "12:00", "12:10" ], [ "13:00", "13:10" ], [ "14:00", "14:10" ] ]    # many periods
#
# weekly:  days = subarray of [1, ..., 7] or substring of "1234567"
# monthly: days = subarray of [1, ... , 31]
# year:    days = subarray of [1, ... , 366]
#
# in code: delay(duration)
# in code: label("give a short name for logging")
# in code: register for initialization


daily(time) do
  :L001 = @switch
end

# nightly do
#   :ExteriorLights = @switch
# end


sunrise do
  puts $date
end
