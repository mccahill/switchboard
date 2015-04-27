class AdminController < ApplicationController
  
  before_filter :onlyAdmin
      
  def initialize_sdn_controller
    r = RyuController.new
    r.initialize_sdn(@user)
    redirect_to('/net_config_transactions/sort?curDir=false&curOrder=id&order=id')
  end
  
  def playback_to_sdn
    r = RyuController.new
    r.playback_commands_from_stack(@user) 
    # show them what just happened
    redirect_to('/net_config_transactions/sort?curDir=false&curOrder=id&order=id')
  end

  def get_sdn_config
    r = RyuController.new
    r.current_sdn_status(@user)
    # show them what just happened
    redirect_to('/net_config_transactions/sort?curDir=false&curOrder=id&order=id')
  end
    
  def index
  end
  
  def links
    @links = LinkRequest.valid
    render 'links/index'
  end

  def subnets
    @subnets = OwnerObject.where(ownable_type: 'Subnet')
    @owner_objs = OwnerObject.where(ownable_type: 'Ip')
    @vlan_objs = OwnerObject.where(ownable_type: 'Vlan')
  end

  def ajax_get_groups
    render json: OwnerGroup.all.map { |og| og.id == 1 ? {name:'', value:1} : {name: og.name, value: og.id} }   
  end
  
  def ajax_get_members
    g = OwnerGroup.find params[:id]
    render json: g.users.map {|m|{name: m.displayName, value: m.id}}  
  end
  
  def ajax_set_group
    oo = OwnerObject.find(params[:id])
    oo.owner_group = OwnerGroup.find(params[:group])
    oo.save
    render json: {:name =>oo.owner_group.name, :text =>"Changed the group for #{oo.ownable.display} to #{oo.owner_group.name}"}
  end
  
  def add_subnet
    new_obj = nil
    if params[:cidr].presence
      new_obj = Subnet.create(cidr: params[:cidr])
    else
      new_obj = Ip.create(fqdn: params[:ip])
    end
    return redirect_to admin_subnets_path, notice: "Failed to create: #{new_obj.errors.full_messages.join(", ")}" if new_obj.invalid?
    og = OwnerGroup.find params[:new_group].first
    og.owner_objects.create(ownable: new_obj)
    redirect_to admin_subnets_path, notice: "Sucessfully added #{og.owner_objects.first.ownable_type}"
  end
  
  def add_vlan
    new_obj = nil
    new_obj = Vlan.create(vlan_name: params[:vlan_name], description: params[:description])
    return redirect_to admin_subnets_path, notice: "Failed to create: #{new_obj.errors.full_messages.join(", ")}" if new_obj.invalid?
    og = OwnerGroup.find params[:new_group].first
    og.owner_objects.create(ownable: new_obj)
    redirect_to admin_subnets_path, notice: "Sucessfully added #{og.owner_objects.first.ownable_type}"
  end
  
  def not_supported
    return redirect_to admin_subnets_path, notice: "this feature is not currently supported"
  end
 
  #
  # some code to allow visualizations of the basic SDN setup we have defined
  #
  def switch_setup
    @switch_setup_csv = "source,target,value,notes\n"
    
    @my_switches = Switch.all
    @my_switches.each do |switch|
      switch.switch_configs.each do |config|
        vlan_clause = ''
        if !config.vlan.nil? && !config.vlan.blank?
          vlan_clause = " vlan #{config.vlan}" 
        end 
        
        # deduce which network this is from the address
        this_ip = IPAddress config.ip
        network_value = "#{this_ip.network}/#{this_ip.network.prefix}#{vlan_clause}"
        
        line = "#{switch.description},#{network_value},#{network_value} - #{config.network_type},#{config.ip}#{vlan_clause}\n"
        @switch_setup_csv += line
      end
    end    
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @switch_setup_csv.to_json }
      format.csv  { render :layout => false, :text => @switch_setup_csv }
    end    
  end
  
  def d3_switch_setup
    # D3.org force directed graph of the network suitable for iframe-ing    
    render layout: 'iframe'
  end

  def visualize_switch_setup
    # container page with the D3.org force directed graph of the network in an iframe
  end
   
  
end
