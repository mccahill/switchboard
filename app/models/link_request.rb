class LinkRequest < ActiveRecord::Base
  belongs_to :user
  has_many :approvals, autosave: true
  accepts_nested_attributes_for :approvals
  enum traffic:[ :ip_only, :layer_2]
  has_many :activities, :dependent => :delete_all
  
  after_create :create_activity
  
  #####################################################################
  # Validations
  #####################################################################

  validates :comment, presence: true
  validates :duration, presence: true
  validates :duration, numericality:{ only_integer: true }
  
  validate :uniqueness_of_ips
  validate :path_uniqueness
  
  # Override the icky representation of the nested model
  def self.human_attribute_name(attribute, options = {})  
    return "Requested Host" if (attribute.to_s == "approvals.ip.fqdn")
    attribute
  end
  
  # return a symbol for the current status
  def status
    s = :approved
    approvals.each do |a|
      case a.status
      when :pending, :error, :denied, :revoked, :deleted
        s = a.status
        break
      end
    end
    return s
  end
 
  # return a human readable version of the status
  def status_description()
    s = ''
    approvals.each do |a|
      s<< "#{a.ip.short_fqdn}: #{a.display_status}<br/>"
    end
    s.html_safe
  end
  
  def display
    approvals.each.collect{|a|a.ip.short_fqdn}.join(" to ")
  end
  
  # Send an email to concerned parties if necessary
  def send_approval_request
    # Build a list of all the approvers
    list = []
    approvals.each do |a|
      list += a.ip.owner_group.users.collect{|u| u.email }.uniq.compact unless [:tacit, :approved].include? a.status
    end
    puts "list is #{list}"
    SwitchboardMailer.approval_request_email(list.uniq, self).deliver unless list.blank?
  end
  
  # The originator approves this by default.
  def initial_approvals(user)
    set_final(:tacit, user)
    check_if_done
  end
  
  def approve_by(user)
    set_final(:approved, user)
    check_if_done
  end
  
  def deny_by(user)
    set_final(:denied, user)
  end

  def delete_by(user)
    set_final(:deleted, user)
    # configure the SDN link via the RYU router commands
    r = RyuController.new
    r.remove_static_routes(approvals[0].ip.addr, approvals[1].ip.addr, approvals[0].ip.vlan.vlan_name, approvals[1].ip.vlan.vlan_name )
  end
  
  def revoke_by(user)
    set_final(:revoked, user)
    # configure the SDN link via the RYU router commands
    r = RyuController.new
    r.remove_static_routes(approvals[0].ip.addr, approvals[1].ip.addr, approvals[0].ip.vlan.vlan_name, approvals[1].ip.vlan.vlan_name )
  end
  
  def can_be_approved_by(user)
    cba = false
    approvals.each do |a|
      cba ||= (a.status == :pending and  a.owner_group.users.include? user)
    end
    cba
  end
  
  def owned_by(user)
    cba = false
    approvals.each do |a|
      cba ||= a.owner_group.users.include? user
    end
    cba
    
  end
  
  def create_activity
    Activity.create(user: user, verb: 'create', link_request: self, occurred: Time.now)
  end
  
  # CLASS METHODS
  def self.getApprovalsForUser(user=nil)
    if user.blank?
      LinkRequest.joins(:approvals).where("approvals.status = 'PENDING'").uniq
    else
      LinkRequest.joins(approvals: [owner_group: :users]).where("owner_groups_users.user_id = ? " +
        " AND approvals.status = 'PENDING'", user.id).uniq
    end
  end
  
  # Return all requests that are fully approved and still valid 
  def self.valid
    self.includes(approvals: :ip).collect{|lr| lr if (lr.status == :approved) && (lr.end >= Time.now)}.compact
  end
  
  
  def path_uniqueness
    LinkRequest.valid.each do |lr|
      apps = lr.approvals.collect{|a|a.ip}
      match = true
      approvals.each do |myapp|
        match &&= apps.include? myapp.ip
      end
      if match
        errors.add(:"approvals.ip.fqdn", "not unique: this link already exists") if errors[:"approvals.ip.fqdn"].blank? 
        break
      end
    end
  end

  private
  # Check ips to see if we have duplicates.  The IP object may not be saved yet so we'd better calculate it.
  def uniqueness_of_ips
    hash = {}
    approvals.each do |a|
      addr = a.ip.addr.blank? ? a.ip.calc_addr : a.ip.addr
      if hash[addr]
       # This line is needed to inform the parent to error out, otherwise the save would still happen
        errors.add(:"approvals.ip.fqdn", "nonunique host error") if errors[:"approvals.ip.fqdn"].blank? 
      end
      hash[addr] = true
    end
  end
  
  # If completely approved, set start and end dates
  def check_if_done
    return unless status == :approved
    self.start = Time.now
    self.end = Time.now + (duration.to_i).month
    self.save validate: false
    
    # set up the SDN link via the RYU router commands
    r = RyuController.new
    
    r.connect_via_static_routes(approvals[0].ip.addr, approvals[1].ip.addr, approvals[0].ip.vlan.vlan_name, approvals[1].ip.vlan.vlan_name )
  end
  
  def set_final(state, user)
    approvals.each do |a|
      a.set_final_status(state, user)
    end
  end
  
end
