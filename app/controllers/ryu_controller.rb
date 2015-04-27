class RyuController < ApplicationController
  
  require 'rest_client'
  require 'ipaddr'
  require 'ipaddress'
  
  before_filter :onlyAdmin
  
  
  def index
  end
  
  def log_transaction( who, desc, target, cmd, status, result )
    n = NetConfigTransaction.new
    n[:who] = who
    n[:description] = desc
    n[:target] = target
    n[:command] = cmd
    n[:status] = status
    n[:response] = result
    n.save!    
  end

  def sdn_controller_url
      APP_CONFIG["SDN_CONTROLLER_URL"]
  end
  
  def push_command_onto_stack( new_command )
    # we need to be able to replay commands in order, so save this to the command stack
    save_cmd = ControllerCommandStack.new
    save_cmd.command = new_command
    save_cmd.save!
  end
  
  def playback_commands_from_stack( as_this_user )
    @user = as_this_user
    @stack = ControllerCommandStack.all
    @stack.each do | cmd |
      begin
        my_status = eval( cmd.command )
      rescue => error_message
        result = { :error => error_message }
        log_transaction( @user[:netid], 'playback', "#{cmd.command}", "#{cmd.id}", 'ERROR', result )
        # if there is a problem talking to the controller return an error and bail out
        return( result )
      else
        result = JSON.parse my_status  
        pretty_result = JSON.pretty_generate(result) 
        log_transaction( @user[:netid], 'playback', "#{cmd.command}", "#{cmd.id}", 'OK', pretty_result )
      end
    end
    # if we got here, everything worked
    return( {:result => 'OK'} )
  end
  
  
  def switch_status( the_switch )
    the_switch_status = nil
    begin
      cmd = "RestClient.get '#{sdn_controller_url}/router/#{the_switch}/all'"
      # push_command_onto_stack( cmd )
      my_status = eval( cmd )
    rescue => error_message
      result = { :error => error_message }
      log_transaction( @user[:netid], "switch status\t#{the_switch}", "#{sdn_controller_url}", "/router/#{the_switch}/all", 'ERROR', result )
      return nil
    else
      the_switch_status = JSON.parse my_status  
      pretty_switch_status = JSON.pretty_generate(the_switch_status)  
      log_transaction( @user[:netid], "switch status\t#{the_switch}", "#{sdn_controller_url}", "/router/#{the_switch}/all", 'OK', pretty_switch_status )
      return the_switch_status
    end
  end
  
  def find_id_for_address( the_switch, the_address, the_vlan )
    switch_desc = switch_status( the_switch )
    switch_desc.each do |net_desc|
      switch_desc.first["internal_network"].each do |net_desc|
        if !net_desc["address"].nil? 
          net_desc["address"].each do |address_desc| 
            if ((address_desc["gateway"].to_s == the_address.to_s ) && (net_desc["vlan_id"].to_s == the_vlan.to_s))
              return address_desc["address_id"]
            end
          end
        end
      end
    end
    return nil # we didn't find any addresses that match
  end
  
  
  def find_id_for_gateway( the_switch, the_gateway, the_vlan )
    switch_desc = switch_status( the_switch )
    switch_desc.each do |net_desc|
      switch_desc.first["internal_network"].each do |net_desc|
        if !net_desc["route"].nil? 
          net_desc["route"].each do |route_desc| 
            if ((route_desc["gateway"].to_s == the_gateway.to_s ) && (net_desc["vlan_id"].to_s == the_vlan.to_s))
              return route_desc["route_id"]
            end
          end
        end
      end
    end
    return nil # we didn't find any gateways that match
  end
  
  
  def find_id_for_static_route( the_switch, the_destination, the_gateway, the_vlan )
    switch_desc = switch_status( the_switch )
    switch_desc.each do |net_desc|
      switch_desc.first["internal_network"].each do |net_desc|
        if !net_desc["route"].nil? 
          net_desc["route"].each do |route_desc| 
            if ((route_desc["gateway"].to_s == the_gateway.to_s ) && (route_desc["destination"].to_s == the_destination.to_s) && (net_desc["vlan_id"].to_s == the_vlan.to_s))
              return route_desc["route_id"]
            end
          end
        end
      end
    end
    return nil # we didn't find any routes that match
  end
  
  
  def add_route_to_switch( the_route, the_switch, the_vlan )
    begin
      if the_vlan.nil? || the_vlan == ''
        the_vlan_clause = ''
      else
        the_vlan_clause = "/#{the_vlan}"
      end
      cmd = "RestClient.post '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}', 
                              {:address => '#{the_route}'}.to_json, 
                              {:accept => 'application/json' }"
      push_command_onto_stack( cmd )
      my_status = eval( cmd )
    rescue => error_message
       result = { :error => error_message }
       log_transaction( @user[:netid], "add route to switch\t#{the_route}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}\t#{the_route}", 'ERROR', result )
    else
       result = JSON.parse my_status
       sdn_result = result.first["command_result"].first["result"]
       sdn_details = result.first["command_result"].first["details"]
       log_transaction( @user[:netid], "add route to switch\t#{the_route}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}\t#{the_route}", "#{sdn_result}", "#{sdn_details}" )
    end   
    return result
  end
 
  
  def delete_address_from_switch( the_address, the_switch, the_vlan )
    if the_vlan.nil? || the_vlan == ''
      the_vlan_clause = ''
    else
      the_vlan_clause = "/#{the_vlan}"
    end
    
    delete_this = find_id_for_address( the_switch, the_address, the_vlan )
    if delete_this.nil? then
      result = "cannot find #{the_address} on switch #{the_switch}#{the_vlan_clause}"
      log_transaction( @user[:netid], "delete from switch\t#{the_address}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
    else
      begin      
        # the rest client library does not directly support sending a payload in a REST delete 
        # so we get to call low-level functions to do that
        delete_clause = "{'address_id': '#{delete_this}'}"
        cmd = "RestClient::Request.execute( method: :delete, 
                                     url: '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}',
                                     payload: \"#{delete_clause}\" )"
        push_command_onto_stack( cmd )
        my_status = eval( cmd )                             
      rescue => error_message
         result = { :error => error_message }
         log_transaction( @user[:netid], "delete from switch\t#{the_address}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
      else
         if my_status.nil? then # when deletes work we get a nil status back
           sdn_result = "success"
           sdn_details = ""         
         else
           result = JSON.parse my_status
           sdn_result = result.first["command_result"].first["result"]
           sdn_details = result.first["command_result"].first["details"]
         end
         log_transaction( @user[:netid], "delete from switch\t#{the_address}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", "#{sdn_result}", "#{sdn_details}" )
      end  
    end   
    return result
  end
  
  
  def add_gateway_to_switch( the_gateway, the_switch, the_vlan )
    begin
      if the_vlan.nil? || the_vlan == ''
        the_vlan_clause = ''
      else
        the_vlan_clause = "/#{the_vlan}"
      end
      
      cmd = "RestClient.post '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}',
                       {:gateway => '#{the_gateway}'}.to_json,
                       {:accept => 'application/json' }" 
      push_command_onto_stack( cmd )
      my_status = eval( cmd )                 
    rescue => error_message
       result = { :error => error_message }
       log_transaction( @user[:netid], "add gateway to switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
    else
       result = JSON.parse my_status
       sdn_result = result.first["command_result"].first["result"]
       sdn_details = result.first["command_result"].first["details"]
       log_transaction( @user[:netid], "add gateway to switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", "#{sdn_result}", "#{sdn_details}" )
    end     
    return result
  end

  def delete_gateway_from_switch( the_gateway, the_switch, the_vlan )
    if the_vlan.nil? || the_vlan == ''
      the_vlan_clause = ''
    else
      the_vlan_clause = "/#{the_vlan}"
    end
    
    delete_this = find_id_for_gateway( the_switch, the_gateway )
    if delete_this.nil? then
      result = "cannot find #{the_gateway} on switch #{the_switch}#{the_vlan_clause}"
      log_transaction( @user[:netid], "delete from switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
    else
      begin
        # the rest client library does not directly support sending a payload in a REST delete 
        # so we get to call low-level functions to do that
        delete_clause = "{'route_id': '#{delete_this}'}"
        cmd = "RestClient::Request.execute( method: :delete, 
                                     url: '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}',
                                     payload: \"#{delete_clause}\" )"                             
        push_command_onto_stack( cmd )
        my_status = eval( cmd )                              
      rescue => error_message
         result = { :error => error_message }
         log_transaction( @user[:netid], "delete from switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
      else
        if my_status.nil? then # when deletes work we get a nil status back
          sdn_result = "success"
          sdn_details = ""         
        else
          result = JSON.parse my_status
          sdn_result = result.first["command_result"].first["result"]
          sdn_details = result.first["command_result"].first["details"]
        end
         log_transaction( @user[:netid], "delete from switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", "#{sdn_result}", "#{sdn_details}" )
      end     
    end
    return result
  end
  
  def add_static_route_to_switch( the_destination, the_gateway, the_switch, the_vlan )
    begin
      if the_vlan.nil? || the_vlan == ''
        the_vlan_clause = ''
      else
        the_vlan_clause = "/#{the_vlan}"
      end
      cmd = "RestClient.post '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}',
                       {:destination => '#{the_destination}', :gateway => '#{the_gateway}' }.to_json,
                       {:accept => 'application/json' }"
      push_command_onto_stack( cmd )
      my_status = eval( cmd )                  
    rescue => error_message
       result = { :error => error_message }
       log_transaction( @user[:netid], "add static route to switch\t#{the_destination}\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
    else
       result = JSON.parse my_status
       sdn_result = result.first["command_result"].first["result"]
       sdn_details = result.first["command_result"].first["details"]       
       log_transaction( @user[:netid], "add static route to switch\t#{the_destination}\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", "#{sdn_result}", "#{sdn_details}" )
    end         
    return result
  end

  def delete_static_route_from_switch( the_destination, the_gateway, the_switch, the_vlan )
    if the_vlan.nil? || the_vlan == ''
      the_vlan_clause = ''
    else
      the_vlan_clause = "/#{the_vlan}"
    end
    
    delete_this = find_id_for_static_route( the_switch, the_destination, the_gateway, the_vlan )
    if delete_this.nil? then
      result = "cannot find gateway #{the_gateway} and destination #{the_destination} on switch #{the_switch} in vlan = #{the_vlan_clause}"
      log_transaction( @user[:netid], "delete static route from switch\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
    else    
      begin
        # the rest client library does not directly support sending a payload in a REST delete 
        # so we get to call low-level functions to do that
        delete_clause = "{'route_id': '#{delete_this}'}"
        cmd = "RestClient::Request.execute( method: :delete, 
                                     url: '#{sdn_controller_url}/router/#{the_switch}#{the_vlan_clause}',
                                     payload: \"#{delete_clause}\" )"
        push_command_onto_stack( cmd )
        my_status = eval( cmd )                              
      rescue => error_message
         result = { :error => error_message }
         log_transaction( @user[:netid], "delete static route from switch\t#{the_destination}\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", 'ERROR', result )
      else
        if my_status.nil? then # when deletes work we get a nil status back
          sdn_result = "success"
          sdn_details = ""         
        else
          result = JSON.parse my_status
          sdn_result = result.first["command_result"].first["result"]
          sdn_details = result.first["command_result"].first["details"]
        end
         log_transaction( @user[:netid], "delete static route from switch\t#{the_destination}\t#{the_gateway}\t#{the_vlan_clause}", "#{sdn_controller_url}", "/router/#{the_switch}#{the_vlan_clause}", "#{sdn_result}", "#{sdn_details}" )
      end
    end     
    return result
  end
  
  
  def current_sdn_status( as_this_user )
    @user = as_this_user
    begin
      cmd = "RestClient.get '#{sdn_controller_url}/router/all/all'"
      # push_command_onto_stack( cmd )
      my_status = eval( cmd )
    rescue => error_message
      result = { :error => error_message }
      log_transaction( @user[:netid], 'current sdn status', "#{sdn_controller_url}", '/router/all/all', 'ERROR', result )
    else
      result = JSON.parse my_status  
      pretty_result = JSON.pretty_generate(result) 
      log_transaction( @user[:netid], 'current sdn status', "#{sdn_controller_url}", '/router/all/all', 'OK', pretty_result )
    end
    return result
  end
      
      
  def get_switch_addresses
    # to simplify dynamic creation of static routes use a hash to keep track 
    # of how the switches connect to the hub switch, but since that might be different depending on
    # the vlan, we have to return switch the IPs keyed to VLAN
    #
    # the hash returned should look something like this:
    #
    #    { nil =>   {'0000000000000001' => "172.16.47.1", 
    #                '0000000000000002' => "172.16.47.2", 
    #                '0000000000000003' => "172.16.47.3" },
    #     '667' => { '0000000000000001' => "172.17.47.1", 
    #               '0000000000000002' => "172.17.47.2", 
    #               '0000000000000003' => "172.17.47.3" }}
    #
    # we expect to index into the has by vlan and switch name to get IP like this:
    #      get_switch_addresses[vlan][switch_name]
    
    final_result = {}
    interconnect = SwitchConnectionType.find_by_name('SDN interconnect')
    SwitchInitialConfig.find_by_sql("SELECT DISTINCT vlan FROM switch_initial_configs").each do |a_vlan|
      if a_vlan.vlan.nil? 
        vlan_clause = "vlan IS NULL"
        vlan_name = nil
      elsif a_vlan.vlan == ''
        vlan_clause = "vlan = '' "
        vlan_name = nil
      else
        vlan_clause = "vlan = #{a_vlan.vlan}"
        vlan_name = a_vlan.vlan
      end
      this_vlan = {}
      SwitchInitialConfig.find_by_sql("SELECT * FROM switch_initial_configs 
                                       WHERE switch_connection_type_id = #{interconnect.id} 
                                       AND #{vlan_clause}").each do |config|
        the_switch = Switch.find(config.switch_id)
        non_cidr_ip = (IPAddress config.ip).address
        this_vlan["#{the_switch.name}"] = "#{non_cidr_ip}"  
      end
      if this_vlan.length > 0 
        final_result[ vlan_name ] = this_vlan
      end
    end
    return final_result
  end

  def get_hub_address
    # to simplify dynamic creation of static routes use a hash to keep track 
    # of switches connections to the hub switch -- note there may be different hubs for the various vlans
    
    result_array = []
    hub_switch = Switch.find_by_hub(true)
    SwitchInitialConfig.where(switch_id: hub_switch.id).each do |config|
      non_cidr_ip = (IPAddress config.ip).address
      result_array.push({:vlan=>config.vlan, :switch_id=>hub_switch.name, :switch_ip=>non_cidr_ip})
    end
    return result_array
  end
  
  def initialize_sdn( as_this_user )
    @user = as_this_user 
    @starting_status = current_sdn_status(@user)
    SwitchInitialConfig.find_each do |config|
      add_route_to_switch( config.ip, Switch.find(config.switch_id).name, config.vlan )
    end          
    @ending_status = current_sdn_status(@user)  
  end
  
  
  def find_switch_for( ip_address, ip_vlan )
    # assumption: the ip_address is connected to at most 1 sdn switch
    synthetic_user = {:netid => 'sdnFindSwitch'}
    @ryu_status = current_sdn_status(synthetic_user)
    @ryu_status.each do |switch_desc|
      switch_desc["internal_network"].each do |net_desc|
        if net_desc["address"].nil? then 
          # special case: there are no networks configured
        else
          net_desc["address"].each do |addr_desc|
             # is the ip_address in the subnet and the vlan they are on ?
             if (IPAddr.new(addr_desc["address"].to_s).include? ip_address ) && (ip_vlan.to_s == net_desc["vlan_id"].to_s)
               return( switch_desc["switch_id"] )
             end
          end
        end
      end
    end
    # didn't find anything
    return( nil )
  end
  
  
  def connect_via_static_routes( ip_one, ip_two, vlan_one, vlan_two )    
    # assume that the topology is super-simple: a single SDN hub with no hosts on it, 
    # and each SDN switch with hosts connected is connect directly to the hub

    # find the switches that server the two IP addresses
    ip_one_switch_id = find_switch_for( ip_one, vlan_one )
    ip_two_switch_id = find_switch_for( ip_two, vlan_two )
    
    if ip_one_switch_id.nil? 
      log_transaction( 'sdnStaticRoute', "Static route create failed: cannot find switch for \t#{ip_one} \t#{vlan_one}", "", "", "", "" )
    elsif ip_two_switch_id.nil?
      log_transaction( 'sdnStaticRoute', "Static route create failed: cannot find switch for \t#{ip_two} \t#{vlan_two}", "", "", "", "" )
    else 
      # construct static routes on switches and the Hub 
      hub_ip_address = get_hub_address.first[:switch_ip]
      hub_id = get_hub_address.first[:switch_id]
      hub_vlan = get_hub_address.first[:vlan]
      if  hub_vlan == '' 
        hub_vlan = nil
      end
      
      # this will need to change when we start supporting vlan tag flipping
      get_hub_address.each do |hub_desc| 
        if hub_desc[:vlan] == vlan_one
          hub_vlan = hub_desc[:vlan]
          if  hub_vlan == '' 
            hub_vlan = nil
          end
          hub_ip_address = hub_desc[:switch_ip]
          hub_id = hub_desc[:switch_id]
        end
      end           
      add_static_route_to_switch( "#{ip_two}/32", hub_ip_address, ip_one_switch_id, hub_vlan )
      add_static_route_to_switch( "#{ip_one}/32", hub_ip_address, ip_two_switch_id, hub_vlan )
      add_static_route_to_switch( "#{ip_one}/32", get_switch_addresses[vlan_one][ip_one_switch_id], hub_id, vlan_one )
      add_static_route_to_switch( "#{ip_two}/32", get_switch_addresses[vlan_two][ip_two_switch_id], hub_id, vlan_two )
    end    
  end


  def remove_static_routes( ip_one, ip_two, vlan_one, vlan_two )
    # assume that the topology is super-simple: a single SDN hub with no hosts on it, 
    # and each SDN switcht with hosts connected is connect directly to the hub

    # find the switches that server the two IP addresses
    ip_one_switch_id = find_switch_for( ip_one, vlan_one )
    ip_two_switch_id = find_switch_for( ip_two, vlan_two )
  
    if ip_two_switch_id.nil? 
      log_transaction( 'sdnStaticRoute', "Static route remove failed: cannot find switch for \t#{ip_one} \t#{vlan_one}", "", "", "", "" )
    elsif ip_two_switch_id.nil?
      log_transaction( 'sdnStaticRoute', "Static route remove failed: cannot find switch for \t#{ip_two} \t#{vlan_two}", "", "", "", "" )
    else 

      hub_vlan = nil
      hub_ip_address = get_hub_address.first[:switch_ip]
      hub_id = get_hub_address.first[:switch_id]
      get_hub_address.each do |hub_desc| # this will need to change when we start supporting vlan tag flipping
        if hub_desc[:vlan] == vlan_one
          hub_vlan = hub_desc[:vlan]
          hub_ip_address = hub_desc[:switch_ip]
          hub_id = hub_desc[:switch_id]
        end
      end           
      # remove static routes on switches and the Hub
      delete_static_route_from_switch( "#{ip_two}/32", hub_ip_address, ip_one_switch_id, hub_vlan )
      delete_static_route_from_switch( "#{ip_one}/32", hub_ip_address, ip_two_switch_id, hub_vlan )
      delete_static_route_from_switch( "#{ip_one}/32", get_switch_addresses[hub_vlan][ip_one_switch_id], hub_id, vlan_one  )
      delete_static_route_from_switch( "#{ip_two}/32", get_switch_addresses[hub_vlan][ip_two_switch_id], hub_id, vlan_two  )
    end    
  end


  def del_routes( as_this_user )
    @user = as_this_user 
    # remove some routes (useful for testing, but not something for production)
    # delete_address_from_switch( "10.185.47.1/30", '0000000000000001' )
    # delete_static_route_from_switch( "10.185.0.0/26", "10.185.47.5", '0000000000000003' )       
    @delete_route_status = current_sdn_status(@user)
  end
  
end
