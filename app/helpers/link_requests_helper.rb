module LinkRequestsHelper
  def buildOwnerGroup(app)
    list = app.ip.owner_group.users.each.collect{|u| u.displayName}.join('</li><li>')
    s = "<a href='#' title='Owning Group: #{app.ip.owner_group.name}<br/><ul><li>#{list}</li></ul>'>
    #{app.ip.short_fqdn} VLAN: #{app.ip.vlan.display}</a> #{app.display_status}<br/>"
    
    s = "<a href='#' title='Owning Group: #{app.ip.owner_group.name}<br/><ul><li>#{list}</li></ul>'>#{app.ip.short_fqdn} "
    if (!app.ip.vlan.blank?)
      if (!app.ip.vlan.vlan_name.blank?)
        s += "VLAN: #{app.ip.vlan.display}"
      end
    end
    s += "</a> #{app.display_status}<br/>"
    
    ret = %Q{

    }
    return s.html_safe
  end
end
