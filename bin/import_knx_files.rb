#!/usr/bin/env ruby

require 'rubygems'
require 'mysql'
require 'active_record'
require 'pry'
require 'rexml/document'

require 'zip'
require 'zip/filesystem'

knxprj = ENV["HOME"]+'/ownCloud/ruby/padrino/knxbrowse/spec/app/models/0.xml'

class Node < ActiveRecord::Base
  store :content, coder: JSON
end

class Referencetype < ActiveRecord::Base
end
class Nodetype < ActiveRecord::Base
end
class Idx < ActiveRecord::Base
end

# CREATE USER 'knx'@'localhost' IDENTIFIED BY 'knx';
# GRANT ALL PRIVILEGES ON knx.* TO 'knx'@'localhost' identified by 'knx';

def connect_drop_create
    ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "knx",
    :password => "knx",
    :database => "knx"
  )

  ActiveRecord::Base.connection.execute "DROP database knx;"
  ActiveRecord::Base.connection.execute "CREATE database knx;"
  ActiveRecord::Base.connection.execute "USE knx;"
  ActiveRecord::Base.connection.execute <<SQL
  CREATE TABLE nodes (
  idx     INTEGER PRIMARY KEY,
  xparent INTEGER,
  xtype   VARCHAR (255),
  idk      TEXT,
  refid   TEXT,
  content TEXT
  );
SQL
  ActiveRecord::Base.connection.execute "CREATE TABLE referencetypes ( id INTEGER PRIMARY KEY AUTO_INCREMENT, nodetype VARCHAR (255), refname VARCHAR (255));"
  ActiveRecord::Base.connection.execute "CREATE TABLE nodetypes      ( name VARCHAR (255) PRIMARY KEY);"
  ActiveRecord::Base.connection.execute "CREATE TABLE idxes (idk VARCHAR(255) PRIMARY KEY, idx INTEGER);"

end


def save(xid, element, parent_id)

  data = {}
  element.attributes.each { |k,v|   data[k] = v }

  n = Node.new(idx: xid)

  name = element.name.capitalize

  n.xtype   = name
  n.xparent = parent_id
  n.idk     = data.delete("Id")
  n.refid   =  data.delete("RefId")

  @ntype[name]        = true
  @xid[n.idk]         = xid    if n.idk

  data.each do |k,v|
    n.content[k] = v

    if /RefId\Z/ =~ k
      @rtype[name] ||= {}
      @rtype[name][k] = true
    end

  end
  n.save
end

def import(element, parent_id=nil)

  if !parent_id
    @globalid = 0
  else
    @globalid += 1
  end

  this_id = @globalid

  save(this_id, element, parent_id)
  element.each_element { |e| import(e, this_id) }
end

def unfold_reftype
  reftype = []
  @rtype.each do |k,v|
    v.keys.each do |rt|
      reftype << [k,rt]
    end
  end
  reftype
end

connect_drop_create


# read ETS4 project export file
puts "Reading #{knxprj}"
doc = REXML::Document.new File.read(knxprj)

@rtype = {}
@ntype = {}
@xid  = {}

ActiveRecord::Base.transaction do
  import(doc.root)

  unfold_reftype.each {|k,rt| Referencetype.create(nodetype: k, refname: rt) }

  @ntype.keys.sort.each {|t|  Nodetype.create(name: t) }
  @xid.each {|idk, xid|       Idx.create(idk: idk, idx: xid)}
end

puts "IMPORT knxproj ok!"

# binding.pry
