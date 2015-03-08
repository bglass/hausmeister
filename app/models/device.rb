class Device


  @@lut = {}

  def initialize(address, name=nil)
    address = address.to_i
    @address = address
    @name    = name
    @@lut[name]    = self
    @@lut[address] = self
  end

  def self.import
    EtsDeviceInstance.pluck(:Address, :Name).each do |a, n|
      Device.new(a, n)
    end
  end

  def self.find(arg)
argdup = arg & 0b0000000011111111  # DBG, line and area are to be included.
      @@lut[argdup]
  end

  def address
    addr = [ ( @address & 0b1111000000000000 ) >> 12,
             ( @address & 0b0000111100000000 ) >> 8,
               @address & 0b0000000011111111 ]
    addr.join('.')
  end

  def name
    if !@name
      address
    elsif /\A[\w\d]+\Z/ =~ @name
      '@' + @name
    else
      "[#{@name}]"
    end
  end

  def to_s
    name
  end

end
