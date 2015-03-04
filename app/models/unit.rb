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

      channel = device_comobjects(device)

    end
  end


  def self.device_comobjects(index)
    channel = {}
    binding.pry
    coirs = index.com_object_instance_ref
    coirs.each do |coir|

      cor = coir.com_object_ref
      co  = cor.com_object

      d = {}
      channel[cor.name] ||= []

      d[:Function]  = cor.function
      d[:objectnum] = cor.objectnum

      connector = coir.send_receive

      connector.each do |sr|
        srtype = ( sr.xtype == "EtsReceive" ? "(Rx)" : "" )
        d[sr.ets_group_address.address] = "#{sr.ets_group_address.Name} #{srtype}"
      end
      channel[cor.name] << d
    end
    channel.sort_by{|c,d| c}
  end


end
