# Helper methods defined here can be accessed in any controller or view in the application

  # RSPEC_TBD
module Knxbrowse
  class App
    module TableHelper

      def sorted_node_summary(type)
        nodes = Nodetype.find_type(type)
        nodes.map{|i|
          # i = Index.new(n)
          [i.summary, i.idx]}.sort_by{|s,x| s
          }
      end

    end

    helpers TableHelper
  end
end
