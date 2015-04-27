class Vlan < ActiveRecord::Base
  has_one :owner_object, :as => :ownable
  has_many :ips
  
  
  def display
    "#{vlan_name} #{description}"
  end
  
  
end
