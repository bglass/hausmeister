# Helper methods defined here can be accessed in any controller or view in the application

  # RSPEC_TBD
module Knxbrowse
  class App
    module SiteHelper


      def render_site_data
        # binding.pry
        buildings = Nodetype.find_type("EtsBuildings")
        nids = site_add_children!(buildings.first, 0)
        render_site_item(nids)
      end

      def render_site_item(nids)

        items = nids.map do |n|
          if n.is_a? Array
            render_site_item(n)
          else
            label = n.summary
            linkurl  = url_for(:node, :id => n.idx)
            link     = link_to( label, linkurl)
            content_tag(:li, link)
          end
        end
        content_tag(:ul, items.join.html_safe)
      end


      def site_add_children!(nid, rec)
        # binding.pry
        if nid.table.to_s != @stoptype and rec < 20
          cc = nid.children.map do |cid|
            # cid = Index.new(c)
            cid = cid.follow_if_reference
            site_add_children!(cid, rec+1)
          end
          [nid, cc]
        else
          [nid]
        end
      end
    end

    helpers SiteHelper
  end
end
