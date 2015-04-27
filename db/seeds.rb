admins = OwnerGroup.create(name: 'sysadmins')
u1 = User.create(netid: 'liz', duid: '0489988', displayName: 'Liz Wendland', email: 'liz@duke.edu')
u2 = User.create(netid: 'mccahill', duid: '0435319', displayName: 'Mark P McCahill', email: 'mark.mccahill@duke.edu')
u3 = User.create(netid: 'tempusc', duid: '0339288', displayName: 'Arthur Fugit', email: 'tempus.c.fugit@duke.edu')
admins.users = [u1, u2]
admins.save

vlandefault = Vlan.create(description: 'default')
vlaninstance = Vlan.create(vlan_name: '666', description: 'the beast')
vlanowners = OwnerGroup.create(name: 'VLAN Owners group')
vlanowners.users = [u1, u2]
vlanowners.save
vlanowners.owner_objects.create(ownable: vlaninstance)
vlaninstance2 = Vlan.create(vlan_name: '667', description: 'non beastly')
vlanowners.owner_objects.create(ownable: vlaninstance2)


s = Subnet.create(cidr: '172.16.96.0/25')
og = OwnerGroup.create(name: 'S1 Owners group')
og.users << [u1,u3]
og.save
og.owner_objects.create(ownable: s)
ip = Ip.create(addr: '172.16.96.16', fqdn: '172.16.96.16', subnet_id: s.id, vlan_id: vlandefault.id)
ip.save

s = Subnet.create(cidr: '172.17.96.0/25')
og.owner_objects.create(ownable: s)
ip = Ip.create(addr: '172.17.96.18', fqdn: '172.17.96.18', subnet_id: s.id, vlan_id: vlaninstance2.id)
ip.save

og2 = OwnerGroup.create(name: 'Test S1 Researchers group')
og2.owner_objects.create(ownable: ip)
og2.users = [u3,u2]
og2.save

s = Subnet.create(cidr: '172.16.8.64/26')
og = OwnerGroup.create(name: 'S2 Owners group')
og.users << u2
og.save
og.owner_objects.create(ownable: s)

s = Subnet.create(cidr: '172.17.8.0/26')
og.owner_objects.create(ownable: s)
ip = Ip.create(addr: '172.17.8.2', fqdn: '172.17.8.2', subnet_id: s.id, vlan_id: vlaninstance2.id)
ip.save

og2 = OwnerGroup.create(name: 'Test S2 Researchers group')
og2.owner_objects.create(ownable: ip)
og2.users = [u3,u2]
og2.save

s = Subnet.create(cidr: '172.16.8.0/26')
og = OwnerGroup.create(name: 'S3 Owners group')
og.users << [u1,u2]
og.save
og.owner_objects.create(ownable: s)
ip = Ip.create(addr: '172.16.8.3', fqdn: '172.16.8.3', subnet_id: s.id, vlan_id: vlandefault.id)
ip.save
og2 = OwnerGroup.create(name: 'Test S3 Researchers group')
og2.owner_objects.create(ownable: ip)
og2.users = [u2,u3]
og2.save

og = OwnerGroup.create(name: 'LSRC')
og.users << [u1,u3]
og.save
og = OwnerGroup.create(name: 'BIO')
og.users << u3
og.save
og = OwnerGroup.create(name: 'PHYSICS')
og.users << u2
og.save

interconnect = SwitchConnectionType.create(name: 'SDN interconnect')
hostnet = SwitchConnectionType.create(name: 'host network')

sw1 = Switch.create(name: '0000000000000002', description: 'hub switch 0000000000000002', hub: true)
sw2 = Switch.create(name: '0000000000000001', description: 'host sw 0000000000000001', hub: false)
sw3 = Switch.create(name: '0000000000000003', description: 'host switch 0000000000000003', hub: false)
sw1.save
sw2.save
sw3.save

sc1 = SwitchInitialConfig.create(switch_id: sw1.id, ip: '172.16.47.1/24', switch_connection_type_id: interconnect.id)
sc2 = SwitchInitialConfig.create(switch_id: sw2.id, ip: '172.16.47.2/24', switch_connection_type_id: interconnect.id)
sc3 = SwitchInitialConfig.create(switch_id: sw3.id, ip: '172.16.47.3/24', switch_connection_type_id: interconnect.id)
sc1.save
sc2.save
sc3.save

sc1vlan = SwitchInitialConfig.create(switch_id: sw1.id, ip: '172.17.47.1/24', vlan: '667', switch_connection_type_id: interconnect.id)
sc2vlan = SwitchInitialConfig.create(switch_id: sw2.id, ip: '172.17.47.2/24', vlan: '667', switch_connection_type_id: interconnect.id)
sc3vlan = SwitchInitialConfig.create(switch_id: sw3.id, ip: '172.17.47.3/24', vlan: '667', switch_connection_type_id: interconnect.id)
sc1vlan.save
sc2vlan.save
sc3vlan.save

sc2host = SwitchInitialConfig.create(switch_id: sw2.id, ip: '172.16.96.120/25', switch_connection_type_id: hostnet.id)
sc3host = SwitchInitialConfig.create(switch_id: sw3.id, ip: '172.16.8.15/26', switch_connection_type_id: hostnet.id)
sc2host.save
sc3host.save

sc2hostvlan = SwitchInitialConfig.create(switch_id: sw2.id, ip: '172.17.96.120/25', vlan: '667', switch_connection_type_id: hostnet.id)
sc3hostvlan = SwitchInitialConfig.create(switch_id: sw3.id, ip: '172.17.8.15/26', vlan: '667', switch_connection_type_id: hostnet.id)
sc2hostvlan.save
sc3hostvlan.save
