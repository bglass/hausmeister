
# Helper methods defined here can be accessed in any controller or view in the application

# RSPEC_TBD
module Knxbrowse
  class App
    module NodeHelper


      def node_link(nid)
        # binding.pry
        label = nid.summary
        link   = uri(url(@path, :id => nid.idx))
        link_to(label, link )
      end

      def node_referer(nid)
        nid.find_referer.map do |r|
          node_link(r)
        end
      end

      def node_children(nid)
        children = nid.follow_if_reference.children
        children.map do |c|
          node_link(c)
        end
      end

      def node_types
        Nodetype.pluck.sort_by {|i,t| t}.map do |i,t|
          count = Nodetype.nclass(i).count
          label = type_humanize(t) + " (#{count})"
          link  = uri(url(:table, :name => t))
          link_to(label, link)
        end
      end

      def type_humanize(t)
        t.gsub(/\AEts/,'').gsub(/([a-z\d])([A-Z])/, '\1 \2')
      end

    end
    helpers NodeHelper
  end
end
