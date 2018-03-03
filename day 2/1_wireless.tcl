
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              670   ;# X dimension of the topography
set val(y)              670   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(seed)           0.0
set val(adhocRouting)   DSR
set val(nn)             3             ;# no of nodes
set val(cp)             "/home/administrator/ns-allinone-2.35/ns-2.35/tcl/mobility/scene/cbr-3-test" 
set val(sc)             "/home/administrator/ns-allinone-2.35/ns-2.35/tcl/mobility/scene/scen-3-test" 
set val(stop)           400.0           ;# simulation time



set ns_		[new Simulator]



set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

set tr1	[open 1_wireless-out.tr w]
$ns_ trace-all $tr1

set nmfile1    [open 1_wireless-out.nam w]
$ns_ namtrace-all-wireless $nmfile1 $val(x) $val(y)


set god_ [create-god $val(nn)] ;#creates tables that stores details of hops

set chan [new $val(chan)]

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
                 -routerTrace OFF \
                 -macTrace OFF 



for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}


puts "Loading csr-3-test..." ;#node mov. model
source $val(cp)


puts "Loading scen-3-test..." ;#traffic model
source $val(sc)



for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}



for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; "

puts "Starting Simulation..."


# declare finish program
proc finish {} {
	global ns_ tr1 nmfile1
	$ns_ flush-trace 
	close $tr1
	close $nmfile1
	exec nam 1_wireless-out.nam & 
	exit 0
}


$ns_ at 400.0 "finish"

$ns_ run
