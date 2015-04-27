class MonitorGlueController < ApplicationController
  # to make it easier to monitor the SDN controller and switches, 
  # we have switchboard grab status info which cen then be passed over to 
  # the monitoring infrastructure

  require 'rest_client'
  require 'ipaddr'
  require 'ipaddress'
  
  def sdn_controller_url
      APP_CONFIG["SDN_CONTROLLER_URL"]
  end
  
  
  def return_status
    respond_to do |format|
      format.html { 
        @monitor_glue_status = JSON.pretty_generate(@monitor_glue_status, 
                opts = {:object_nl => '<br>', 
                        :indent => '&nbsp&nbsp&nbsp&nbsp', 
                        :array_nl => '<br>'})
        render :layout => true
      }
      format.json { render :layout => false, :json => @monitor_glue_status }
    end 
  end
  
  
  def status
    # query the controller here and get back a raw result
    # raw_result = '[ { "internal_network": [ { "route": [ { "source": "0.0.0.0/0", "route_id": 2, "destination": "10.148.177.6/32", "gateway": "10.185.0.36", "gateway_mac": "00:1c:73:65:b1:0d" }, { "source": "0.0.0.0/0", "route_id": 1, "destination": "10.148.177.8/32", "gateway": "10.185.0.36", "gateway_mac": "00:1c:73:65:b1:0d" } ], "address": [ { "address_id": 2, "address": "10.185.0.50/24" }, { "address_id": 1, "address": "10.185.16.62/26" } ] } ], "switch_id": "0000001c73759379" }, { "internal_network": [ { "route": [ { "source": "0.0.0.0/0", "route_id": 3, "destination": "10.148.177.6/32", "gateway": "10.185.0.2", "gateway_mac": "00:1c:73:75:66:0a" }, { "source": "0.0.0.0/0", "route_id": 2, "destination": "10.185.16.6/32", "gateway": "10.185.0.50", "gateway_mac": "00:1c:73:75:93:aa" }, { "source": "0.0.0.0/0", "route_id": 1, "destination": "10.148.177.8/32", "gateway": "10.185.0.2", "gateway_mac": "00:1c:73:75:66:0a" } ], "address": [ { "address_id": 1, "address": "10.185.0.36/24" } ] } ], "switch_id": "0000001c7365b107" }, { "internal_network": [ { } ], "switch_id": "0000001c73662025" }, { "internal_network": [ { "route": [ { "source": "0.0.0.0/0", "route_id": 1, "destination": "10.185.16.6/32", "gateway": "10.185.0.36", "gateway_mac": "00:1c:73:65:b1:0c" } ], "address": [ { "address_id": 2, "address": "10.185.0.2/24" }, { "address_id": 1, "address": "10.148.177.254/24" } ] } ], "switch_id": "0000001c737565d7" }, { "internal_network": [ { } ], "switch_id": "00010a0b0c0d0e0f" } ]'
    # result = JSON.parse raw_result
    controller_status = { :type => "controller", 
                          :id => sdn_controller_url, 
                          :description => "RYU SDN controller",
                          :status => "unknown",
                          :status_error_msg => ""
    }
    
    begin
      cmd = "RestClient.get '#{sdn_controller_url}/router/all/all'"
      # push_command_onto_stack( cmd )
      my_status = eval( cmd )
    rescue => error_message
      controller_status[:status] = "error"
      controller_status[:status_error_msg] = error_message.to_s
      @monitor_glue_status = [ controller_status ]
    else
      controller_status[:status] = "ok"
      @monitor_glue_status = [ controller_status ] 
      result = JSON.parse my_status   
      result.each do | device |
        device_status = { :type => "switch", 
                          :id => device["switch_id"], 
                          :description => "Switch #{device["switch_id"]}",
                          :status => "unknown",
                          :error_detected => false,
                          :status_error_msg => ""
        }
        device_detail = device["internal_network"].first
        if device_detail.length == 0 then
          device_status[:status] = "unconfigured"
          device_status[:error_detected] = true
          device_status[:status_error_msg] = " missing configuration"
        else
          if device_detail["route"].nil? 
            # no routes on this switch
          else
            # look for null MAC addresses since those indicate bad/misconfigured ports on the switch
            device_detail["route"].each do |device_route|
              if device_route["gateway_mac"] = 'null'
                device_status[:error_detected] = true
                device_status[:status_error_msg] += " null gateway MAC address for destination #{device_route["destination"]}"
              end          
            end
          end
          if device_detail["address"].nil?
             # no addresses configured
             device_status[:error_detected] = true
             device_status[:status_error_msg] += " no addresses configured on switch #{device["switch_id"]}"
          else
            device_detail["address"].each do |device_address|
              # look for errors in address configs here
            end
          end
          if device_status[:error_detected] 
            device_status[:status] = "error"
          else
            device_status[:status] = "ok"
          end
        end
        @monitor_glue_status.push( device_status )
      end
    end
    return_status
  end


  private  
  # Override authorize in application_controller.rb
  def authorize
    case request.format
    when Mime::JSON
      #let them have the JSON without jumping through auth hoops
    else
      super
    end
  end
  
end
