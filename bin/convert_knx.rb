#!/usr/bin/env ruby

require 'pry'
require 'active_record'

require_relative "../app/models/database"
require_relative "../app/models/node"
require_relative "../app/models/ets"
require_relative "../app/models/index"
require_relative "../app/models/indexarray"
require_relative "../app/models/nodetype"

#-------------------------------------------------------------------------------

# ActiveRecord::Base.connection.execute("DESCRIBE ets_deviceinstance").each{|r| p r}



tables = {
  :device    => ["idx", "Id", "ProductRefId", "Address", "Name", "Area:Int", "Line:Int"],
  :product   => ["idx", "Id", "Text", "OrderNumber", "Manufacturer:VAR"],
  :coir      => ["idx", "RefId", "DatapointType", "Description"],
  :cor       => ["idx", "Id", "RefId", "FunctionText", "Text", "DatapointType", "Name:VAR", ],
  and/or co ?
  :groupaddress
  :channel / unit
  :dpt





#->


def create_table(table, tdef)
  query = "DROP TABLE IF EXISTS aux_#{table};"
  @db.connection.execute query

  subs = [["INT","INTEGER"],["VAR","VARCHAR(255)"],["INC","AUTO_INCREMENT"]]
  subs.each {|r| tdef = tdef.gsub(/#{r[0]}/,r[1])}
  query = "CREATE TABLE aux_#{table} #{tdef};"
  @db.connection.execute query
end

def create_all_tables
  create_table("device", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_table("refs", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_table("link", "(a_id INT, b_id INT, a_type INT, b_type INT, KEY (a_id, b_id))")
  create_table("node", "(idx INT KEY, name VAR)")
end

#-------------------------------------------------------------------------------

Database.connect
Ets.create_subclasses








binding.pry
