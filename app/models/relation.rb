class Relation < ActiveRecord::Base
  self.abstract_class = true

  def self.create_methods
    Reference.create_relation_methods
    Link.create_relation_methods
  end

  def self.types
    if @types
      @types
    else
      ab = {}
      pluck(:a_id, :b_id).each do |a,b|
        ab[a] ||= {}
        ab[a][b] = true
      end
      @types = ab
    end
  end

  def self.pairs
    reftype = {}
    pluck(:a_type, :b_type).each do |a,b|
      if b
        reftype[a] ||= {}
        reftype[a][b] = true
      end
    end
    reftype
  end

  # Array of Proc
  def self.create_relation_methods

    pairs.each do |a, bx|
      ta = Nodetype.ntype(a)
      bx.keys.each do |b|
        tb = Nodetype.ntype(b)

        methodname = tb.underscore
        relation   = self

        refcolumn = "refid"
        refcolumn = methodname + refcolumn  if self.name != "Reference"

        if Node.dangerous_attribute_method?(methodname)
          puts "WARNING: method name conflict for [#{ta}##{methodname}]. Skipping."
        else
          # puts "Creating #{self.name}: #{ta} => #{methodname}"
          Object.const_get(ta).send :define_method, methodname do
            find_relation(relation, methodname)
          end
        end
      end
    end
  end
end


class Tree < Relation
  self.table_name = "aux_tree"
end

class Reference < Relation
  self.table_name = "aux_refs"
end
class Link < Relation
  self.table_name = "aux_link"
end
