# # RSPEC_TBD
#
#
# class Item
#   attr_accessor :name, :dependants, :value
#
#   @@by_name  = {}
#   @@by_group = {}
#
#
#   def initialize(name,values)
#
#     @name = name
#     @value = "X"
#     (sfx, val) = values.first
#     (@ga, @dpt) = val
#
#     @dependants = []
#
#     @@by_name[@name] = self
#     @@by_group[@ga]  = self
#
#   end
#
#   def to_s ()
#     "vanilla #{self.name} ? #{self.ga}"
#   end
#
#    def self.i2ga(ga)
#     ga = ga.to_i
#     ua =   ga & 0b0000000011111111
#     ma = ( ga & 0b0000011100000000 ) >> 8
#     ha = ( ga & 0b0111100000000000 ) >> 11
#     return "#{ha}/#{ma}/#{ua}"
#   end
#
#
#   def i2ga(ga)
#     ga = ga.to_i
#     ua =   ga & 0b0000000011111111
#     ma = ( ga & 0b0000011100000000 ) >> 8
#     ha = ( ga & 0b0111100000000000 ) >> 11
#     return "#{ha}/#{ma}/#{ua}"
#   end
#
#   def ga3
#     i2ga(@ga)
#   end
#
#   def value=(value)
#     @value = value
#     printf "%s %s = %i\n", @name, i2ga(@ga), @value
#     @dependants.each { |rule|  rule.trigger }          # propagate through  all dependent logic
#   end
#
#   def self.receive(ldframe)    # delegator
#     item = @@by_group[ldframe.dst_addr]
#
#     if item
#      item.receive(ldframe)
#     else
# #       binding.pry
#       printf "Rx Unknown group address: %s\n", i2ga(ldframe.dst_addr)
#     end
#   end
#
#   def receive(ldframe)
#     #    puts "Default Item Receive"    # DBG
#     print "Rx "
#     self.value = ldframe.apci_data
#   end
#
#   def self.all_names
#     @@by_name.map { |name, item|   name }
#   end
#
#   def self.by_name(name)
#     @@by_name[name]
#   end
#   def self.by_group(group)
#     @@by_group[group]
#   end
#
# end
#
# class Switch < Item
#   attr_accessor :ga_switch, :dpt_switch
#
#   def initialize(name,values)
#
#     @ga_switch, @dpt_switch = values[' ']
#     values.tap { |x| x.delete(' ') }
#
#     @@by_group[@ga_switch]  = self
#
#     super(name,values)
#   end
#
#   def receive(ldframe)
#     if ldframe.dst_addr == @ga
#       print "Rx "
#       self.value = ldframe.apci_data
# #    else    #DBG
# #      printf "Rx Observed command %s = %s  \n", @name, ldframe.apci_data
#     end
#   end
#
#   def to_s ()
#     "Switch #{self.name} ? #{self.ga} (#{self.dpt})  ! #{self.ga_switch} (#{self.dpt_switch})"
#   end
#
#   def on
#     self.value = 1
#   end
#
#   def off
#     self.value = 0
#   end
# end
#
# class Dimmer < Switch
#   attr_accessor :ga_dimm, :dpt_dimm
#
#
#   def initialize(name,values)
#
#     (@ga_dimm, @dpt_dimm) = values['~']
#     values.tap { |x| x.delete('~') }
#
#     @@by_group[@ga_dimm]  = self
#
#     super(name,values)
#   end
#
#   def to_s ()
#     "Dimmer #{self.name} ? #{self.ga} (#{self.dpt})  ! #{self.ga_switch} (#{self.dpt_switch})  ~ #{self.ga_dimm} (#{self.dpt_dimm})"
#   end
#
# end
#
# class Value < Item
#    def initialize(name,values)
#     super
#   end
#
#   def to_s ()
#     "Value #{self.name} ? #{self.ga} (#{self.dpt})"
#   end
# end
