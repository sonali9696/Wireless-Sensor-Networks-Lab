
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              500   ;# X dimension of the topography
set val(y)              400   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(seed)           0.0
set val(adhocRouting)   DSDV
set val(nn)             3             ;# how many nodes are simulated
set val(cp)             "2_cbr-3-test" 
set val(sc)             "2_scen-3-test" 
set val(stop)           150.0           ;# simulation time



set ns_		[new Simulator]



set topo	[new Topography]



set tr1	[open asg2-out.tr w]
set nm1    [open asg2-out.nam w]

$ns_ trace-all $tr1
$ns_ namtrace-all-wireless $nm1 $val(x) $val(y)


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
                 -macTrace ON 



for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}



puts "Loading csr-3-test..." ;#node mov. model
source $val(cp)


puts "Loading scen-3-test..." ;#traffic model
source $val(sc)



for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}



for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; "


puts "Starting Simulation..."


# declare finish program
proc finish {} {
	global ns_ tr1 nm1
	$ns_ flush-trace 
	close $tr1
	close $nm1
	exec nam asg2-out.nam & 
	exit 0
}


$ns_ at 400.0 "finish"

$ns_ run
