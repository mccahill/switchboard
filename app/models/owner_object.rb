class OwnerObject < ActiveRecord::Base
  belongs_to :ownable, :polymorphic => true
  belongs_to :owner_group
  
  def display
    case ownable_type
    when "Subnet"
      ownable.cidr
    when "Ip"
      ownable.fqdn
    when "Vlan"
      ownable.vlan_name
    else
      ownable_type
    end
  end
end
