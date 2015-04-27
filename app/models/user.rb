class User < ActiveRecord::Base
  has_and_belongs_to_many :owner_groups
  has_many :link_requests
  has_many :approvals
  
  def isAdmin?
    return OwnerGroup.where(name: 'sysadmins').first.users.include? self
  end
  
  # Display name - or netid if its not set
  def short_display
    displayName.blank? ? netid : displayName
  end

  # displayName (netid) - or only partial if they're not both set
  def full_display
    if displayName.blank? || netid.blank?
      short_display
    else
      "#{displayName} (#{netid})"
    end
  end
  
  def self.new_from_netid(netid)
    logger.info "creating user #{netid}"
    LdapTool.createUser(netid)
  end

  def self.find_or_create_from_netid(netid)
    u = where(netid: netid).first
    u = new_from_netid(netid) if u.nil?
    u = User.new(netid: netid) if u.nil?
    u
  end
  
end
