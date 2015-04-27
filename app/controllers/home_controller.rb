class HomeController < ApplicationController
  skip_filter :authorize, :only => [:no_access]

  def no_access
    render layout: false
  end
  
  def sdn_status
    @status_csv = "source,target,value,notes\n"
    r = RyuController.new
    synthetic_user = {:netid => 'sdnStat'}
    @ryu_status = r.current_sdn_status(synthetic_user)
    @ryu_status.each do |switch_desc|
      a_switch = Switch.find_by_name( switch_desc["switch_id"].to_s )
      if a_switch.nil?
        switch_name = 'switch ' + switch_desc["switch_id"].hex.to_s(16) #switches may have hexadecimal names
      else
        switch_name = a_switch.description
      end
      switch_desc["internal_network"].each do |net_desc|
        if net_desc["address"].nil? then #special case when there are no networks configured
          @status_csv += "#{switch_name},#{switch_name},unconnected,no networks configured\n"
        else
          
          if net_desc["vlan_id"].blank? 
            vlan_clause = ''
          else
            vlan_clause = " vlan:#{net_desc["vlan_id"]} "
          end
          
          net_desc["address"].each do |addr_desc|
            # figure out what network they are on
            this_ip = IPAddress addr_desc["address"].to_s
             
            network_value = "#{this_ip.network}/#{this_ip.network.prefix}#{vlan_clause}"
            
            @status_csv += "#{switch_name},#{this_ip.network}/#{this_ip.network.prefix}#{vlan_clause},#{network_value},#{switch_name} address#{addr_desc["address_id"]}: #{addr_desc["address"]}#{vlan_clause}\n"
          end
        end
        if !net_desc["route"].nil? then # there are some routes 
          net_desc["route"].each do |route_desc|
            # figure out what network they are on
            if route_desc["destination"].to_s == "0.0.0.0/0" then
              @status_csv += "#{switch_name},default gateway #{route_desc["gateway"]}#{vlan_clause},connected via gateway, gateway:#{route_desc["gateway"]}#{vlan_clause} destintation:#{route_desc["destination"]}#{vlan_clause}\n"
            else
              @status_csv += "#{switch_name},#{route_desc["destination"]}#{vlan_clause},connected via gateway, gateway:#{route_desc["gateway"]}#{vlan_clause} destintation:#{route_desc["destination"]}#{vlan_clause}\n"
            end
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ryu_status.to_json }
      format.csv  { render :layout => false, :text => @status_csv }
    end
    
  end
  
  def d3_sdn
    # sD3.org force directed graph of the network suitable for iframe-ing    
    render layout: 'iframe'
  end

  def visualize_sdn
    # container page with the D3.org force directed graph of the network in an iframe
  end
   
  def logout
    reset_session
    return_to_me = "?returnto=" + url_for('/')
    redirect_to "/Shibboleth.sso/Logout?return=https://shib.oit.duke.edu/cgi-bin/logout.pl" +
    CGI.escape(return_to_me)
  end
end
