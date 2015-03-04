#!/usr/bin/env ruby

# DONE fix double records in aux_tree
# DONE fix wrong values in ets_*:id   (seems to equal idx)
# DONE add parent column in ets_*
# DONE increment node types in tables by 1, except nodetype table.
# DONE change column names to get rid of @ax..@bt in node.rb

# mode = "project"
mode = "file"


# CREATE USER 'knx'@'localhost' IDENTIFIED BY 'knx';
# GRANT ALL PRIVILEGES ON knx.* TO 'knx'@'localhost' identified by 'knx';
# GRANT ALL PRIVILEGES ON knx2.* TO 'knx'@'localhost' identified by 'knx';

#==============================================================================
require 'rubygems'
require 'mysql'
require 'active_record'
require 'pry'
require 'rexml/document'
require 'zip'
require 'zip/filesystem'
#==============================================================================
class Mnode
  attr_accessor :idx, :xparent, :xtype, :idk, :refid, :content, :children
  @@memory = []
  @@i = 0
  def initialize(nparent,xtype,idk,refid,content)
    @xparent  = xparent
    @xtype    = xtype
    @idk      = idk
    @children = []
    @@memory << self
    @content = content
    @idx      = @@i
    @content["idx"] = @idx;
    @@i += 1
  end
  def self.all
    @@memory
  end
end
#==============================================================================

def caramel(term)
  term.to_s.gsub! (/([A-Z]*[a-z\d_]*)/) {|s| s.downcase.capitalize}
end




def connect
  ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "knx",
  :password => "knx",
  :database => "knx2")
end

def drop_create_db
  # @db.connection.execute "DROP database knx2;"
  # @db.connection.execute "CREATE database knx2;"
  @db.connection.execute "USE knx2;"
end

def create_aux_table(table, tdef)
  query = "DROP TABLE IF EXISTS aux_#{table};"
  @db.connection.execute query

  subs = [["INT","INTEGER"],["VAR","VARCHAR(255)"],["INC","AUTO_INCREMENT"]]
  subs.each {|r| tdef = tdef.gsub(/#{r[0]}/,r[1])}
  query = "CREATE TABLE aux_#{table} #{tdef};"
  @db.connection.execute query
end

def create_extra_tables
    create_aux_table("tree", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_aux_table("refs", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_aux_table("link", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_aux_table("node", "(idx INT KEY, name VAR)")
end

def create_tables
  @tables.each do |table, column|
    query = "DROP TABLE IF EXISTS #{table};"
    @db.connection.execute query

    column.delete("idx")
    columns = column.map do |c,l|
      if c == "Text"
        "`#{c}` TEXT"
      else
        "`#{c}` VARCHAR(#{l+10})"
      end
    end
    columns.unshift "idx INTEGER PRIMARY KEY"
    cdef  = columns.join(',')
    query = "CREATE TABLE #{table} (#{cdef});"
    # puts query
    @db.connection.execute query
  end
end
#==============================================================================
def add(element, nparent)
  table = "Ets"+element.name
  @tables[table] ||= {}

  data    = {}
  data["pid"] = nparent.idx   if nparent
  element.attributes.each do |c,v|
    column = caramel(c.gsub(/\W/, '_'))
    data[column] = v
  end

  idk = data["Id"]

  content = {}
  data.each do |c,v|
    content[c] = v
    @tables[table][c] ||= 0
    @tables[table][c] = v.to_s.length if v.to_s.length > @tables[table][c]
  end



  n = Mnode.new(nparent,table,idk,data.delete("RefId"),content)
  @tables[table]["idx"]=1

  xid = n.idx
  @idknode[idk]         = n    if idk

  add_parent(n, nparent)        if nparent

# binding.pry
  n
end

def create_references
  Mnode.all.each do |n|
        # binding.pry
    n.content.each do |k, v|
      if /RefId\Z/ =~ k
        # @rtype[n.xtype] ||= {}
        # @rtype[n.xtype][k] = true
        add_reference(n, v, k)
      end
    end
  end
end


def add_reference(a, refid, refname)
  b = @idknode[refid]


  if b
    if refname == "RefId"
      @refs << [a.idx, b.idx, nodetype2num(a.xtype), nodetype2num(b.xtype)]
    else
      reftype = "Ets"+refname.gsub(/RefId\Z/,'')
      atnum = nodetype2num(a.xtype)
      btnum = nodetype2num(reftype)
      if btnum
        @link << [a.idx, b.idx, atnum, btnum]
      end
    end
  end
end



def add_parent(child, parent)
    @tree << [parent.idx, child.idx, parent.xtype, child.xtype]
end



def import(element, parent_id=nil)
  this_id = add(element, parent_id)
  element.each_element { |e| import(e, this_id) }
end

def import_nodes(mode)
  if mode == "project"
    prj_file = "/home/boris/Downloads/LBW25IP - Initial Setup 2013-08-04.knxproj"
    puts "Opening #{prj_file}"
    Zip::File.open(prj_file) do |archive|

      null_xml  = archive.glob("**/0.xml").first.name
      xml_files = archive.glob("**/*.xml").map{ |f| f.name }
      xml_files.delete null_xml
      xml_files.unshift null_xml
      # xml_files = [null_xml]

      xml_files.each do |fn|
        puts "Reading #{fn}..."
        doc = REXML::Document.new archive.file.read(fn)
        import(doc.root)
      end
    end
  elsif mode == "file"
    knxprj = ENV["HOME"]+'/ownCloud/ruby/padrino/knxbrowse/spec/app/models/0.xml'
    doc = REXML::Document.new File.read(knxprj)
    import(doc.root)
  end
end

def create_nodetypes
  @tables.each { |t,v|  @tdescript[t] = v.keys   }

  @nodetypes = @tables.keys
  @ntmap = @tables.keys.map {|nt|  [nodetype2num(nt), nt] }

  @tree.each do |r|
    r[2] = nodetype2num(r[2])
    r[3] = nodetype2num(r[3])
  end
end

#==============================================================================

# def unfold_reftype
#   reftype = []
#   @rtype.each do |k,v|
#     v.keys.each do |rt|
#       reftype << [k,rt]
#     end
#   end
#   reftype
# end

def nodetype2num(x)
  @nodetypes.find_index(x)
end

#==============================================================================

def db_save_nodes
  ActiveRecord::Base.transaction do
    Mnode.all.each do |m|

      cmd     = "INSERT INTO #{m.xtype} "
      columns = m.content.map{|c,v| "`#{c}`=?"}.join(',')
      query   = "#{cmd} SET #{columns};"

      st = @db.connection.raw_connection.prepare(query)
      st.execute(*m.content.values)
      st.close
    end
  end
end

def db_save(table, data, columns=nil )

  ActiveRecord::Base.transaction do

    if !columns
      columns = data.keys
      data    = data.values
    end

    cmd     = "INSERT INTO #{table} "
    cdef    = columns.map{|c| "#{c}=?"}.join(',')
    query   = "#{cmd} SET #{cdef};"

    data.each do |record|
      st = @db.connection.raw_connection.prepare(query)
      st.execute(*record)
      st.close
    end
  end
end

#==============================================================================

# @rtype    = {}
@idknode      = {}
@tables   = {}
@tree     = []
@refs     = []
@link     = []
@tdescript = {}

#==============================================================================
#==============================================================================

import_nodes(mode)
create_nodetypes
create_references


puts "Creating new tables..."
@db = connect
drop_create_db
create_tables
create_extra_tables


puts "Writing to database..."
db_save_nodes

puts "Saving Tree..."
db_save("aux_tree", @tree, ["a_id","b_id","a_type","b_type"])
puts "Saving References..."
db_save("aux_refs", @refs, ["a_id","b_id","a_type","b_type"])
puts "Saving Links..."
db_save("aux_link", @link, ["a_id","b_id","a_type","b_type"])
puts "Saving Node Index..."
db_save("aux_node", @ntmap, ["idx","name"])


# binding.pry


puts "IMPORT knxproj ok!"

#==============================================================================
