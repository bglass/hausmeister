# require 'bindata'
# require_relative 'EIBConnection'
# require_relative 'knx_protocol'





class KNX
  @transmit_buffer = []      # TBC
  @receive_buffer  = []      # TBC
  @cache           = {}      # TBC




  def initialize
    (@@knx, @@vbm, @@knxbuf) = open
  end


  def open
    knx = EIBConnection.new()
    knx.EIBSocketURL(ENV['URL_eibd'])
    vbm = knx.EIBOpenVBusmonitor()
    knxbuf = EIBBuffer.new()
    return knx, vbm, knxbuf
  end

  def close(knx)
    knx.EIBClose
  end







  def value?(group)
    return value
  end

  def write(group)
  end

  def read       # synchronous
    return group, value
  end



  def event_handler     #  (Thread 3)
    puts "KNX Handler started."

    loop do
      len = @@knx.EIBGetBusmonitorPacket(@@knxbuf)
      ldataframe = L_DATA_Frame.read(@@knxbuf.buffer.pack('c*'))
      Item.receive(ldataframe)
    end

  end
end


# class KNXframe
#   attr_accessor :frame
#
#
#   def initialize(value)
#     @frame = value
#   end
#
#   def to_s    # mainly for DBG
# #    binding.pry
#     if item = Item.by_group(@frame.dst_addr)
#       name = item.name
#     else
#       name = "<unknown>"
#     end
#     sprintf "KNX Frame: %s %s = %s \n", item.name, item.ga3, @frame.apci_data   # DBG
#
#   end
# end

class L_DATA_Frame < BinData::Record
  endian :big
  # octet 0: TP1 control field
  bit2    :lpdu_code, { :display_name => "LPDU (2bit) 2=L_DATA.req 3=L_Poll_data.req"}
  bit1    :rep_flag,  { :display_name => "Repeat flag"}
  bit1    :ack_not,   { :display_name => "0 = Acknowledge frame, 1 = standard frame"}
  bit2    :prio_class,{ :display_name => "Priority class (0=highest .. 3=lowest)"}
  bit2    :unused1,   { :display_name => "two unused bits (should be 00)"}
  # octet 1+2: source
  uint16  :src_addr,  { :display_name => "Source Address"}
  # octet 3+4: destination
  uint16  :dst_addr,  { :display_name => "Destination Address"}
  # octet 5: control fields
  bit1    :daf,       { :display_name => "Dest.Address flag 0=physical 1=group"}
  bit3    :ctrlfield, { :display_name => "Network control field"}
  bit4    :datalength,{ :display_name => "Data length (bytes after octet #6)"}
  # octet 6 + octet 7: TPCI+APCI+6-bit data
  bit2    :tpci,      { :display_name => "TPCI control bits 8+7"}
  bit4    :seq,       { :display_name => "Packet sequence"}
  bit4    :apci,      { :display_name => "APCI control bits"}
  bit6    :apci_data, { :display_name => "APCI/Data combined"}
  # octet 8 .. end
  string  :data, {
    :read_length => lambda { datalength - 1 },
    :display_nane => "rest of frame"
  }
end
