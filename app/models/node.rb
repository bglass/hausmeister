class Node < ActiveRecord::Base
  self.abstract_class = true

  # String
  def ntype
    self.class.name
  end

  # Class
  def nclass
    Object.const_get(ntype)
  end

  # Array of Strings
  def columns
    nclass.column_names
  end

  # Trueclass
  def self.column?(cname)
    column_names.include?(cname)
  end

  # Hash
  def data
    d = {}
    columns.each {|c| d[c] = self.send(c)}
    d.delete("idx")
    d.delete("pid")
    d
  end

  # Index
  def parent
    begin
      Index.new(pid)
    rescue
      nil
    end
  end

  # RSPEC_TBD
  # String
  def address(symbol=nil)
    arg = self.Address
    if symbol
      num  = arg.to_i
      addr = [ ( num & 0b0111100000000000 ) >> 11,( num & 0b0000011100000000 ) >> 8, num & 0b0000000011111111 ]
      addr.join(symbol)
    else
      arg
    end
  end

end
