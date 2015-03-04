class Unit

  attr_accessor :name, :children, :index

  def initialize (name: name, index: index)
    @name  = name
    @index = index
  end

  # Array of EtsDeviceInstance
  def self.create_devices

    Nodetype.find_type("EtsDeviceInstance").map do |device|

      puts device.summary
      channel = {}

      channel = find_channels(device)

    end
  end


  def self.find_channels(index)
    channel = {}
    coirs = index.di__com_object_instance_ref
    coirs.each do |coir|

      cor = coir.coir__com_object_ref
      co  = cor.cor__com_object

      d = {}
      channel[cor.name] ||= []

      d[:Function]  = cor.function_text
      d[:objectnum] = cor.cor__objectnum

      connector = coir.coir__send_receive

      connector.each do |sr|
    # binding.pry
        srtype = ( sr.table.name == "EtsReceive" ? "(Rx)" : "" )
        d[sr.links.first.address] = "#{sr.links.first.name} #{srtype}"
      end
      channel[cor.name] << d
    end
    channel.sort_by{|c,d| c}
  end
end
