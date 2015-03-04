ENV['version'] = '0.2'

ENV['groupfile'] = './lbw25etsgroups.xml'
ENV['knxprojfile'] = './0.xml'
ENV['userfile'] = './user.rb'
ENV['group-prefix'] = ':'
ENV['debug'] = '2'                # -1: silent, 0: errors, 1: warnings, 2+: verbose


ENV['knxproj_installation_path']   = "Project/Installations/Installation/"
ENV['knxproj_groupaddress_path']   = "GroupAddresses/GroupRanges/GroupRange/GroupRange/GroupAddress"
ENV['knxproj_comobject_path']      = "Topology/Area/Line/DeviceInstance/ComObjectInstanceRefs/ComObjectInstanceRef"
ENV['knxproj_groupref_send_path']  = "Connectors/Send"
ENV['knxproj_groupref_recv_path']  = "Connectors/Receive"

ENV['latitude']  = "52.215850"
ENV['longitude'] = "4.416102"


ENV['URL_eibd'] = 'ip:192.168.1.5'
