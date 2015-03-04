
# Helper methods defined here can be accessed in any controller or view in the application

# RSPEC_TBD
module Knxbrowse
  class App
    module NodeHelper

      def device_instance(nid)
        d = {}

        pid = nid.ets_product
        location, trade      = nid.location_and_trade

        d[:Address]      = nid.address
        d[:Name]         = nid.Name
        d[:Line]         = node_link(nid.line)    if nid.line
        d[:Location]     = node_link(location)  if location
        d[:Trade]        = node_link(trade)     if trade
        d[:Product]      = pid.Text
        d[:Type]         = pid.OrderNumber
        d[:Manufacturer] = pid.manufacturer.Name
        d
      end

      def device_comobjects(nid)
        channel = {}

        coirs = nid.com_object_instance_ref
        coirs.each do |coir|
          cor = coir.com_object_ref
          co  = cor.com_object

          d = {}
          channel[cor.name] ||= []

          d[:Function]  = cor.function
          d[:objectnum] = cor.objectnum

          connector = coir.send_receive

          connector.each do |sr|
            srtype = ( sr.xtype == "EtsReceive" ? "(Rx)" : "" )
            d[sr.ets_group_address.address] = "#{sr.ets_group_address.Name} #{srtype}"
          end
          channel[cor.name] << d
        end
        channel.sort_by{|c,d| c}
      end

    end
    helpers NodeHelper
  end
end
