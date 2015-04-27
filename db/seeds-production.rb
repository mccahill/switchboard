admins = OwnerGroup.create(name: 'sysadmins')
u1 = User.create(netid: 'liz', duid: '0489988', displayName: 'Liz Wendland', email: 'liz@duke.edu')
u2 = User.create(netid: 'mccahill', duid: '0435319', displayName: 'Mark P McCahill', email: 'mark.mccahill@duke.edu')
u3 = User.create(netid: 'jdorff', duid: '0381669', displayName: 'Jimmy Dorph', email: 'jdorff@phy.duke.edu')
admins.users = [u1, u2]
admins.save
vlandefault = Vlan.create(description: 'default')

s = Subnet.create(cidr: '10.148.177.0/24')
og = OwnerGroup.create(name: 'Physics')
og.users << [u1,u2,u3]
og.save
og.owner_objects.create(ownable: s)

s = Subnet.create(cidr: '10.185.16.0/26')
og = OwnerGroup.create(name: 'BioPhysics')
og.users << [u1,u2,u3]
og.save
og.owner_objects.create(ownable: s)

hostnet = SwitchConnectionType.create(name: 'host network')
interconnect = SwitchConnectionType.create(name: 'SDN interconnect')

sw1 = Switch.create(name: '0000001c7365b107', description: 'Telcom hub 0000001c7365b107', hub: true)
sw2 = Switch.create(name: '0000001c73759379', description: 'Biosci 0000001c73759379', hub: false)
sw3 = Switch.create(name: '0000001c737565d7', description: 'Physics 0000001c737565d7', hub: false)
sw4 = Switch.create(name: '00010a0b0c0d0e0f', description: 'ATC 00010a0b0c0d0e0f', hub: false)
sw5 = Switch.create(name: '0000001c73662025', description: 'CSci North 011 0000001c73662025', hub: false)
sw1.save
sw2.save
sw3.save
sw4.save
sw5.save

sc1 = SwitchInitialConfig.create(switch_id: sw1.id, ip: '10.185.1.1/24', switch_connection_type_id: interconnect.id)
sc2 = SwitchInitialConfig.create(switch_id: sw2.id, ip: '10.185.1.2/24', switch_connection_type_id: interconnect.id)
sc3 = SwitchInitialConfig.create(switch_id: sw3.id, ip: '10.185.1.3/24', switch_connection_type_id: interconnect.id)
sc4 = SwitchInitialConfig.create(switch_id: sw3.id, ip: '10.185.1.4/24', switch_connection_type_id: interconnect.id)
sc5 = SwitchInitialConfig.create(switch_id: sw3.id, ip: '10.185.1.5/24', switch_connection_type_id: interconnect.id)
sc1.save
sc2.save
sc3.save
sc4.save
sc5.save

sc2host = SwitchInitialConfig.create(switch_id: sw2.id, ip: '10.185.16.62/26', switch_connection_type_id: hostnet.id)
sc3host = SwitchInitialConfig.create(switch_id: sw3.id, ip: '10.148.177.254/24', switch_connection_type_id: hostnet.id)
sc5host = SwitchInitialConfig.create(switch_id: sw5.id, ip: '152.3.9.0/25', switch_connection_type_id: hostnet.id)
sc2host.save
sc3host.save
sc5host.save
