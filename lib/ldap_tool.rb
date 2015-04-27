class LdapTool
  require 'net/ldap'
  
  LDAP_HOST = "ldap.duke.edu"
  TREEBASE =  "DC=duke,DC=edu"
  
  def LdapTool.createUser(netid)
    attrs = ["displayName", "uid", "dudukeid",'telephonenumber','mail']
    auth = {:method => :anonymous}
    ldap_con = Net::LDAP.new(:host => LDAP_HOST,:port => 636,:encryption => :simple_tls, :auth =>auth)
    op_filter = Net::LDAP::Filter.construct("uid=#{netid}")
    ldapArray = ldap_con.search( :base =>TREEBASE, :filter => op_filter, :attrs=>attrs, :return_result=>true)
    return nil if ldapArray.blank? or ldapArray.size >1

    anames = ldapArray.first.attribute_names
    u = User.new
    u.netid = anames.include?(:uid) ? ldapArray.first.uid.first : nil
    u.displayName = anames.include?(:displayname) ? ldapArray.first.displayname.first : 'Missing'
    u.duid = anames.include?(:dudukeid) ? ldapArray.first.dudukeid.first : nil
    u.phone = anames.include?(:telephonenumber) ? ldapArray.first.telephonenumber.first : 'Missing'
    u.email = anames.include?(:mail) ? ldapArray.first.mail.first : 'Missing'
    u.save
    return u

  end

  def LdapTool.userLookup(searchStr)
    return nil if searchStr.blank?

    attrs = ["displayName", "uid"]
    ldap_con = Net::LDAP.new(:host => LDAP_HOST,:port => 636,:encryption => :simple_tls, :auth =>{:method => :anonymous})

    if !/ /.match(searchStr)     # Single word case
      j = Net::LDAP::Filter.eq('uid', searchStr)
      k  = Net::LDAP::Filter.eq('givenname', searchStr)
      l  = Net::LDAP::Filter.eq('cn', searchStr)
      m  = Net::LDAP::Filter.eq('sn', searchStr)
      op_filter = (k|l|j|m)   #match netid firstname or nickname and their last name
    else
      words = searchStr.split(" ")
      words.each do | word|
        word.concat("*") if (/\*/.match(word)).nil?
      end
      k  = Net::LDAP::Filter.eq('givenname', words[0])
      l  = Net::LDAP::Filter.eq('cn', "#{words[0]} #{words[1]}")
      op_filter = (k|l)
      op_filter  = (op_filter & Net::LDAP::Filter.eq('sn', words[words.size - 1])) if words.size>1
    end

    retArray = {}
    ldapArray = ldap_con.search( :base => TREEBASE, :filter => op_filter, :size=>15, :return_result=>false) do |e|

      if e.attribute_names.include?(:uid)
        name = e.attribute_names.include?(:displayname) ? "#{e.displayname.first} (#{e.uid.first})" : e.uid.first
        retArray[e.uid.first] = name
      end

    end
    return retArray
  end
end