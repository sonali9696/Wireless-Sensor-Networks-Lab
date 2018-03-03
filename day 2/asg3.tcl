set opt(chan)       Channel/WirelessChannel
set opt(prop)       Propagation/TwoRayGround
set opt(netif)      Phy/WirelessPhy
set opt(mac)        Mac/802_11
set opt(ifq)        Queue/DropTail/PriQueue
set opt(ll)         LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)              2200   ;# X dimension of the topography
set opt(y)              500   ;# Y dimension of the topography
set opt(ifqlen)         50            ;# max packet in ifq
set opt(seed)           0.0
set opt(adhocRouting)   AODV
set opt(nn)             9             ;# how many nodes are simulated
set opt(stop)           150.0           ;# simulation time

set ns_		[new Simulator]
set topo	[new Topography]
set tracefd	[open asg3.tr w]
set namtrace    [open asg3.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# declare finish program
proc finish {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace 
	close $tracefd
	close $namtrace
	exec nam asg3.nam & 
	exit 0
}

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# Create God
set god_ [create-god $opt(nn)]

# define how node should be created
#global node setting
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 		 -topoInstance $topo \
		 		 -agentTrace ON \
                 -movementTrace ON \
                 -routerTrace ON \
                 -macTrace ON 

#  Create the specified number of nodes [$opt(nn)] and "attach" them to the channel. 
for {set i 0} {$i < $opt(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

$node_(0)  set X_ 50
$node_(0)  set Y_ 250
$node_(0)  set Z_ 0

$node_(1)  set X_ 250
$node_(1)  set Y_ 250
$node_(1)  set Z_ 0

$node_(2)  set X_ 450
$node_(2)  set Y_ 250
$node_(2)  set Z_ 0

$node_(3)  set X_ 650
$node_(3)  set Y_ 250
$node_(3)  set Z_ 0

$node_(4)  set X_ 850
$node_(4)  set Y_ 250
$node_(4)  set Z_ 0

$node_(5)  set X_ 1050
$node_(5)  set Y_ 250
$node_(5)  set Z_ 0

$node_(6)  set X_ 1250
$node_(6)  set Y_ 250
$node_(6)  set Z_ 0

$node_(7)  set X_ 1450
$node_(7)  set Y_ 250
$node_(7)  set Z_ 0

$node_(8)  set X_ 1650
$node_(8)  set Y_ 250
$node_(8)  set Z_ 0

for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

# Define node movement model and traffic model

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(8) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 1.0 "$ftp start"

# Tell nodes when the simulation ends
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}

$ns_ at  $opt(stop).0002 "puts \"NS EXITING...\" ;"
puts "Starting Simulation..."

$ns_ at 150.0 "finish"
$ns_ run
