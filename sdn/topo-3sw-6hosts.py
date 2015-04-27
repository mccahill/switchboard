from mininet.topo import Topo

class MyTopo( Topo ):

    def __init__( self ):
        "Create custom topo"
        # Iniialize topology
	
	Topo.__init__( self )

	# Add hosts and Switches
	leftHost1 = self.addHost( 'h1' )
	leftHost2 = self.addHost( 'h2' )
	midHost1 = self.addHost( 'h3' )
	midHost2 = self.addHost( 'h4' )
	rightHost1 = self.addHost( 'h5' )
	rightHost2 = self.addHost( 'h6' )
	leftSwitch = self.addSwitch( 's1' )
	midSwitch = self.addSwitch( 's2' )
	rightSwitch = self.addSwitch( 's3' )

	# add links
	self.addLink( leftHost1, leftSwitch )
	self.addLink( leftHost2, leftSwitch )
	self.addLink( leftSwitch, midSwitch )
	self.addLink( midHost1, midSwitch )
	self.addLink( midHost2, midSwitch )
	self.addLink( midSwitch, rightSwitch )
	self.addLink( rightHost1, rightSwitch )
	self.addLink( rightHost2, rightSwitch )

topos = { 'mytopo': ( lambda: MyTopo() ) } 


