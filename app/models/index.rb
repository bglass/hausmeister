class Index

  attr_accessor :idx, :table, :node

  def initialize(idx, table: nil, node: nil)
    @idx   = idx
    @table = table
    @node  = node
  end

  def node
    table if !@table
    if !@node
      record do #DBG
        n = @table.send "where", "idx=?", @idx
        n.length == 0 ? nil : @node = n.first
      end
    else
      @node
    end
  end

  def table
    if !@table
      record do #DBG
        type_id = Tree.where(b_id: @idx).pluck(:b_type).first
        type_id = 0 unless type_id
        @table  = Nodetype.nclass(type_id)
      end
    else
      @table
    end
  end

  def parent
    record do #DBG
      Index.new( table.where(idx: @idx).pluck(:pid).first )
    end #record DBG
  end

  # Array of subclass of Node
  def children()
    record do #DBG
      IndexArray.new( Tree.where(a_id: self.idx).pluck(:b_id) )
    end #record DBG
  end

  # Trueclass
  def has_children?()   children.length > 0;   end

  # Index
  def find_relation(relation,name=nil)
    record do #DBG
      x = relation.where(a_id: @idx)  # TODO
      if relation.name == "Reference"
        k = x.first
      else
        k = x.select{|r| name == Nodetype.ntype(r.b_type).underscore }.first
      end
      Index.new(k.b_id)
    end #record DBG
  end

  # Subclass of Node
  def reference
    find_relation(Object.const_get("Reference"))
  end

  # IndexArray
  def referers
    record do #DBG
      IndexArray.new(Reference.where(b_id: idx).pluck(:a_id))
    end #record DBG
  end

  def links
    record do #DBG
      IndexArray.new(Link.where(a_id: @idx).pluck(:b_id))
    end #record DBG
  end

  def backlinks
    record do #DBG
      IndexArray.new(Link.where(b_id: @idx).pluck(:a_id))
    end #record DBG
  end

  # Trueclass
  def is_reference?
    has_reference? and table.column_names.count == 3   # idx/pid/refid
  end

  # Trueclass
  def has_reference?
    # binding.pry
    if table.column?("RefId")
      refid = table.where(idx: @idx).pluck(:RefId)
      refid.length > 0
    else
      nil
    end
  end

  # Trueclass
  def is_link?
    has_links? and table.column_names.count == 3   # idx/pid/xxxrefid
  end

  # Trueclass
  def has_links?
    table.column_names.select{|c| c =~ /.+RefId/ }.length > 0
  end

  # Index
  def follow_if_reference()

    if is_reference?
      reference
    else
      self
    end
  end

  # String
  def summary
    fields = ["Type", "Name", "Text"] & table.column_names
    if fields.length > 0
      text = table.where(idx: @idx).pluck(*fields).compact
      # binding.pry
      text.reject!(&:empty?) if text
    end
    text ||= []
    text.unshift @table.name.gsub(/\AEts/,'').underscore.humanize
    text.join(" : ")
  end

  # String
  def name
    text = table.where(idx: @idx).pluck(:Name).first if table.column?("Name")
  end

  # Hash {column => value}
  def data
    node.data
  end



end


#
#
#
#
#
#
#
#
# module EtsDeviceInstanceModule
#
#
#   # Array of subclass of Nodes
#   def com_object_instance_ref
#     coirefs = children.select{|x| x.xtype=="EtsComObjectInstanceRefs"}
#     if coirefs.length == 1
#       c = coirefs.first.children
#       c.first.xtype == "EtsComObjectInstanceRef" ? c : []
#     elsif coirefs.length == 0
#       []
#     else
#       binding.pry   #DBG, should not happen
#     end
#   end
# end
#
# module EtsComObjectInstanceRefModule
#
#   # Node
#   def com_object_ref
#     n = reference
#     n.xtype == "EtsComObjectRef" ? n : nil
#   end
#
#   # Node
#   def com_object
#     n = reference.reference
#     n.xtype == "EtsComObject" ? n : nil
#   end
#
#   # Array of Nodes
#   def send_receive
#     # binding.pry
#
#     children_count = children.size
#
#     # c = children
#     if children_count == 1
#       n = children.first.children
#       ["EtsSend","EtsReceive"].include?(n.first.xtype) ? n : []
#     elsif children_count > 1
#       binding.pry
#     else
#       []
#     end
#   end
# end
#
# module EtsComObjectRefModule
#   # Node
#   def com_object
#     n = reference
#     n.xtype == "EtsComObject" ? n : nil
#   end
#
#
