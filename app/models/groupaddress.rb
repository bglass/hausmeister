class Groupaddress

  attr_reader :dpt


  @@lut = {}

  def initialize(address, idx=nil, name=nil)
    address = address.to_i
    @address = address
    @name    = name
    @index   = Index.new(idx)
    @@lut[name]    = self
    @@lut[address] = self

    if @index.backlinks.length > 0             # DB Heavy
      bl = @index.backlinks.first
      @dpt = bl.parent.parent.node.DatapointType
    end


  end

  def self.import
    EtsGroupAddress.pluck(:Address, :idx, :Name).each do |a, i, n|
      Groupaddress.new(a, i, n)
    end
  end

  def self.find(arg)
      @@lut[arg]
  end

  def address
    addr = [ ( @address & 0b0111100000000000 ) >> 11,
             ( @address & 0b0000011100000000 ) >> 8,
               @address & 0b0000000011111111 ]
    addr.join('/')
  end

  def name
    if !@name
      address
    elsif /\A[\w\d]+\Z/ =~ @name
      ':' + @name
    else
      "<#{@name}>"
    end
  end

  def to_s
    name
  end

end
