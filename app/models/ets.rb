module Ets

  # Array of Class
  def self.create_subclasses
    Nodetype.sorted_names.map do |t|
      Object.const_set(t, Class.new(Node) do
        self.table_name = "#{t}"
        mname = t+"Module"
        if Object.const_defined? mname
          include Object.const_get mname
        end
      end
      )
    end

  end

  def self.initialize_tables
    Groupaddress.import
    Device.import
  end
end

module EtsProductModule
  def summary
    self.Text
  end

  # Node
  def manufacturer
    n = self
    while n.parent and n.xtype != "EtsManufacturer"
      n = n.parent
    end
    while !n.Name and n.reference
      n = n.reference
    end
    n.xtype == "EtsManufacturer" ? n : n
  end
end

module EtsLineModule
  def summary
    "#{self.Name} (#{address})"
  end
  def address
    super('*')
  end
end

module EtsDeviceInstanceModule

  def summary
    if ets_product
      "#{self.Name} (#{ets_product.Text})"
    elsif self.Name
      "#{self.Name}"
    else
      "[#{self.Id}]"
    end
  end
  def address
    super('.')
  end

  def line
    n = parent
    n.xtype == "EtsLine" ? n : nil
  end

  def location_and_trade
    location = trade = nil
    referers.each do |r|
      rp = r.parent
      location  = rp   if  ["EtsRoom", "EtsBuildingpart"].include? rp.xtype
      trade     = rp   if   rp.xtype == "EtsTrade"
    end
    return location, trade
  end

  # Array of subclass of Nodes
  def com_object_instance_ref
    coirefs = children.select{|x| x.xtype=="EtsComObjectInstanceRefs"}
    if coirefs.length == 1
      c = coirefs.first.children
      c.first.xtype == "EtsComObjectInstanceRef" ? c : []
    elsif coirefs.length == 0
      []
    else
      binding.pry   #DBG, should not happen
    end
  end
end

module EtsComObjectInstanceRefModule

  # Node
  def com_object_ref
    n = reference
    n.xtype == "EtsComObjectRef" ? n : nil
  end

  # Node
  def com_object
    n = reference.reference
    n.xtype == "EtsComObject" ? n : nil
  end

  # Array of Nodes
  def send_receive
    # binding.pry

    children_count = children.size

    # c = children
    if children_count == 1
      n = children.first.children
      ["EtsSend","EtsReceive"].include?(n.first.xtype) ? n : []
    elsif children_count > 1
      binding.pry
    else
      []
    end
  end

  




end

module EtsComObjectRefModule
  # Node
  def com_object
    n = reference
    n.xtype == "EtsComObject" ? n : nil
  end

  def name
    self.Text ? self.Text : com_object.Name
  end
  def function
    self.Text ? self.FunctionText : com_object.FunctionText
  end
  def objectnum
    com_object.Number
  end
end

module EtsGroupAddressModule

  def address
    super('/')
  end
end
