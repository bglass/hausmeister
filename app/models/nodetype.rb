class Nodetype < ActiveRecord::Base
  self.table_name = "aux_node"

  def self.sorted_names
    pluck(:name).sort
  end
  # String

  def self.ntype(type_id)
    record do #DBG
      where(idx: type_id).pluck(:name).first
    end #record DBG
  end

  # Class
  def self.nclass(type_id)
    t = ntype(type_id)
    Object.const_get(t)
  end


  # Array of subclass of Node
  def self.find_type(type)
    IndexArray.new( (Object.const_get(type).send "all").pluck(:idx) )
  end


end
