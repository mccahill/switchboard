class Subnet < ActiveRecord::Base
  has_one :owner_object, :as => :ownable
  # has_many :owner_groups, :through=>:owner_objects
  has_many :ips
  
  validates_presence_of :cidr
  validate :subnet_format
  
  def Subnet.forIp(ip)
    self.all.each do |s|
      return s if (IPAddr.new(s.cidr).include? ip)
    end
    return nil
  end
  
  #private
  
  def subnet_format
    begin
      ip1 = IPAddress.parse cidr
      errors.add(:cidr, "This CIDR is not a valid network") unless ip1.network?
    rescue Exception => e
      errors.add(:cidr, "This is not a valid IPv4 Address")
    end
  end
end
