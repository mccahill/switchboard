require 'resolv'

class Ip < ActiveRecord::Base
  has_one :owner_object, :as => :ownable
  belongs_to :subnet
  belongs_to :vlan
  has_many :approvals
  
  before_validation :set_ip
  validate :validate_dns   
  
  # We don't know if they gave us the fqdn or the ip in the fqdn.  
  def set_ip
    return false if fqdn.blank?
    begin
      ip = IPAddress.parse fqdn
      # if that didn't blow up, fqdn is the ip
      ip = fqdn
      self.fqdn = Resolv.getname ip
      
    rescue Exception => e
      ip = calc_addr
    end
    
    return false if ip.blank?

    logger.info "you are adding #{ip}"
      
    self.subnet = Subnet.forIp(ip) 
    self.addr = ip
    return true
  end
  
  def calc_addr
    Resolv.getaddresses(fqdn).first
  end

  def short_fqdn
    addr == fqdn ? addr : fqdn.split('.').first
  end
  
  # Does this dnsName resolve?
  def validate_dns
    return if fqdn.blank?
    ip4s = Resolv.getaddresses(fqdn)
    if ip4s.count > 1
      errors.add(:fqdn, "#{fqdn} resolves to multiple IPs (#{ip4s.inspect})")
      return
    end
    if ip4s.blank?
      return errors.add(:fqdn, "#{fqdn} can't be resolved ") 
    end
    ip = ip4s.first
    ipRecord = Ip.where( addr: ip )       # TODO: what if the dnsName changed?
    
    if ipRecord.blank?
       subnet = Subnet.forIp(ip) 
       errors.add(:fqdn, "Address is not on an SDN subnet") if subnet.blank?
       # ipRecord = self.create(addr: ip, fqdn: dnsName, subnet: subnet)
     end
  end
  
  def owner_group
    
    # This IP may have an owner group or it may inherit from its subnet
    
    if owner_object.blank?
      return subnet.owner_object.owner_group
    else
      return owner_object.owner_group
    end
  end
  
  def display
    if vlan.vlan_name.nil?
      a_vlan_clause = ''
    else
      a_vlan_clause = " VLAN: #{vlan.vlan_name} #{vlan.description}"
    end
    "#{fqdn} (#{addr}#{a_vlan_clause})"
  end
  
end
