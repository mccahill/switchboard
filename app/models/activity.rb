require 'csv'
class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :link_request
  belongs_to :ip
  
  def self.to_csv(acts)
    CSV.generate do |csv|
      csv << column_names
      acts.each do |act|
        row = []
        Activity.column_names.each do |col|
          row << case col
          when 'ip_id'
            act.ip.short_fqdn unless act.ip.blank?
  #        when 'vlan_id'
  #          act.ip.vlan.display unless act.ip.vlan.blank?
          when 'user_id'
            act.user.displayName
          when 'link_request_id'
            act.link_request.approvals.each.collect{|a|"#{a.ip.short_fqdn}"}.join("|")
          else
            act.send(col)
          end
        end
        csv << row
      end
    end
  end
end
