#!/usr/bin/env ruby



require 'rubygems'
require 'mysql'
require 'active_record'
require 'pry'
require 'rexml/document'
require 'zip'
require 'zip/filesystem'

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
# GRANT ALL PRIVILEGES ON knx2.* TO 'knx'@'localhost' identified by 'knx';

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
  idx     INTEGER PRIMARY KEY AUTO_INCREMENT,
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


def save(element, parent_id)

  data = {}
  element.attributes.each { |k,v|   data[k] = v }

  n   = Node.create
  xid = n.idx

  name = element.name.capitalize

  if Object.const_defined?(name)
    print "WARNING: name space conflict for type #{name}, "
    name = "KNX_"+name
    puts  "it will be renamed as #{name}."
  end

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
  xid
end

def import(element, parent_id=nil)
  this_id = save(element, parent_id)
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

@rtype = {}
@ntype = {}
@xid  = {}

# read ETS4 project export file

now = 0

prj_file = "/home/boris/Downloads/LBW25IP - Initial Setup 2013-08-04.knxproj"
puts "Opening #{prj_file}"
Zip::File.open(prj_file) do |archive|

  null_xml  = archive.glob("**/0.xml").first.name
  xml_files = archive.glob("**/*.xml").map{ |f| f.name }
  xml_files.delete null_xml
  xml_files.unshift null_xml

  xml_files.each do |fn|
    before = now
    print "Reading #{fn}..."
    doc = REXML::Document.new archive.file.read(fn)
    print "Saving "
    ActiveRecord::Base.transaction do
      import(doc.root)
      # binding.pry

      now = Node.last.idx
      puts "#{now - before} records..."
    end
  end
end

ActiveRecord::Base.transaction do
  unfold_reftype.each {|k,rt| Referencetype.create(nodetype: k, refname: rt) }
  @ntype.keys.sort.each {|t|  Nodetype.create(name: t) }
  @xid.each {|idk, xid|       Idx.create(idk: idk, idx: xid)}
end

puts "IMPORT knxproj ok!"

# binding.pry
