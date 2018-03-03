set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              500   ;# X dimension of the topography
set val(y)              500   ;# Y dimension of the topography
set val(ifqlen)         100            ;# max packet in ifq
set val(seed)           0.0
set val(adhocRouting)   AODV
set val(nn)             100            ;# how many nodes are simulated
set val(stop)           50.0           ;# simulation time


set ns_		[new Simulator]

set topo	[new Topography]



set tracefd	[open 2_AODV_50.tr w]
set namtrace    [open 2_AODV_50.nam w]


proc finish {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace  
	close $tracefd
	close $namtrace
	exec nam 2_AODV_50.nam &
	exit 0
}


$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]



$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channelType $val(chan) \
		 		 -topoInstance $topo \
		 		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movement ON 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}


for {set i 0} {$i < 50 } {incr i} {
	set snode [expr {round(rand()*97)}]
	set dnode [expr {$snode + 2}]
	set udp_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($snode) $udp_($i)
	set null_($i) [new Agent/Null]
	$ns_ attach-agent $node_($dnode) $null_($i)
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ 512
	$cbr_($i) set interval_ 4.0
	$cbr_($i) set random_ 1
	$cbr_($i) set rate_ 0.2
	$cbr_($i) set maxpkts_ 10000
	$cbr_($i) attach-agent $udp_($i)
	$ns_ connect $udp_($i) $null_($i)
	$ns_ at 0.5 "$cbr_($i) start"
}


set god_ [God instance]


for {set i 0} {$i < $val(nn) } {incr i} {
	set x_pos [expr {round(rand()*499)}]
	set y_pos [expr {round(rand()*499)}]	
	$node_($i) set Z_ 0.000000000000
	$node_($i) set Y_ $y_pos
	$node_($i) set X_ $x_pos
}



for {set i 0} {$i < $val(nn)} {incr i} {
    
    $ns_ initial_node_pos $node_($i) 20
}



# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}




$ns_ at 350.0 "finish"
$ns_ run




