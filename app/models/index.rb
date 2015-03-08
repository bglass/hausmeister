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
        n = @table.send "where", {idx: @idx}
        n.length == 0 ? nil : @node = n.first
    else
      @node
    end
  end

  def table
    if !@table
        type_id = Tree.where(b_id: @idx).pluck(:b_type).first
        type_id = 0 unless type_id
        @table  = Nodetype.nclass(type_id)
    else
      @table
    end
  end

  #  DO NOT use @node and @table below this line.
  #  Use caching accessors node and table instead.


  # String
  def value(column)
    table.where(idx: @idx).pluck(column).first if table.column?(column)
  end

  # Index
  def get(column)
    Index.new( table.where(idx: @idx).pluck(column).first)
  end

  # String
  def parent
    get(:pid)
  end

  # Array of subclass of Node
  def children()
      IndexArray.get( Tree, {a_id: self.idx}, :b_id)
  end

  # Trueclass
  def has_children?()   children.length > 0;   end

  # Index
  def find_relation(relation,name=nil)
      x = relation.where(a_id: @idx)  # TODO
      if relation == Reference
        k = x.first
      else
        k = x.select{|r| name == Nodetype.ntype(r.b_type).underscore }.first
      end
      Index.new(k.b_id)
  end

  # Subclass of Node
  def reference
    # find_relation(Object.const_get("Reference"))
    find_relation(Reference)
  end

  # IndexArray
  def referers
      IndexArray.get(Reference, {b_id: @idx}, :a_id)
  end

  def links
      IndexArray.get(Link, {a_id: @idx}, :b_id)
  end

  def backlinks
      IndexArray.get(Link, {b_id: @idx}, :a_id)
  end

  # Trueclass
  def is_reference?
    has_reference? and table.column_names.count == 3   # idx/pid/refid
  end

  # Trueclass
  def has_reference?
    # binding.pry
    if table.column?("RefId")
      # refid = table.where(idx: @idx).pluck(:RefId)
      # refid.length > 0
      value("RefId").length > 0
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
      text.reject!(&:empty?) if text
    end
    text ||= []
    text.unshift table.name.gsub(/\AEts/,'').underscore.humanize
    text.join(" : ")
  end

  def name
    value("Name")
  end

  # String
  def text
    value("Text")
  end

  # String
  def function_text
    value("FunctionText")
  end

  # String
  def address
    value("Address")
  end

  # Hash {column => value}
  def data
    node.data
  end
# end
#
#
# class DeviceInstance < Index

  def di__com_object_instance_ref
    coirefs = children.select{|x| x.table == EtsComObjectInstanceRefs}
    if coirefs.length == 1
      c = coirefs.first.children
      c.first.table == EtsComObjectInstanceRef ? c : []
    elsif coirefs.length == 0
      []
    else
      binding.pry   #DBG, should not happen
    end
  end
# end
#
# class ComObjectInstanceRef < Index

  # Node
  def coir__com_object_ref
    n = reference
    n.table == EtsComObjectRef ? n : nil
  end

  # Node
  def coir__com_object
    n = reference.reference
    n.table == EtsComObject ? n : nil
  end


  # Array of Nodes
  def coir__send_receive

    children_count = children.length

    # c = children
    if children_count == 1
      n = children.first.children
      [EtsSend, EtsReceive].include?(n.first.table) ? n : []
    elsif children_count > 1
      binding.pry
    else
      []
    end
  end

  def coir__dpst
    dpst_id =  EtsComObjectInstanceRef.where(idx: @idx).pluck(:DataPointType).first
    dpst_id ?  Index.new( EtsDatapointSubtype.where(Id: dpst_id).pluck(:idx).first) : nil
  end


# end
#
# class ComObjectRef < Index
  # Node
  def cor__com_object
    n = reference
    n.table == EtsComObject ? n : nil
  end

  def cor__objectnum
    cor__com_object.co__number
  end
# end
#
# class ComObject < Index

  def co__number
    value("Number")
  end

end
