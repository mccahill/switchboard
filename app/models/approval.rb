class Approval < ActiveRecord::Base
  belongs_to :link_request
  validates :ip, :uniqueness => { :scope => :link_request_id }
  belongs_to :ip
  belongs_to :approved_by, class_name: "User"
  belongs_to :owner_group
  accepts_nested_attributes_for :ip
  
  before_save :set_owner_group
  
  # Overwriting default setter/getters
  STATUS = { 
    pending: 'PENDING', 
    tacit: 'TACIT',
    approved: 'APPROVED' , 
    error: "ERROR", 
    denied: "DENIED",
    revoked: "REVOKED",
    deleted: "DELETED",
    none: nil }
    
  def status
    STATUS.key(read_attribute(:status))
  end
  def status=(s)
    write_attribute(:status, STATUS[s])
  end
  
  def status_display
   status == :tacit ? :approved : status
  end
  
  def set_final_status(status, user)
    logger.info "set_final_status says #{owner_group.users.include?( user) }"
    logger.info "status is #{status.to_sym == :deleted }"
    if (owner_group.users.include?( user) )or (status.to_sym == :deleted ) #ACLS for delete check above
      logger.info "and yeah, i will change the status"
      self.status = status
      self.approved_by = user
      self.approved_at = Time.now
      self.save
      Activity.create(user: user, verb: status, link_request: link_request, ip: ip, occurred: Time.now)
    end
  end
  
  def ip_attributes=(params)
    if existing_ip = Ip.find_by_fqdn(params[:fqdn])
      self.ip = existing_ip 
    else
      self.build_ip(params)
    end
  end
  
  def set_owner_group
    self.owner_group = ip.owner_group  # short circuit to make it easier later
  end
  
  def display_status
    case status
    when :pending
      "pending approval from #{ip.owner_group.name}"
    when :tacit
      "tacitly approved by originator #{approved_by.displayName}"
    when :approved
      "approved by #{approved_by.displayName}"
    when :denied
      "denied by #{approved_by.displayName}"
    when :revoked
      "revoked by #{approved_by.displayName}"
    when :error
      "had an error"
    else
      "unknown"
    end
  end
end
