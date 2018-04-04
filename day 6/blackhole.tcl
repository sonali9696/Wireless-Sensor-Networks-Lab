# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

##################################################################
# Modified by Mohit P. Tahiliani and Gaurav Gupta		 #
# Department of Computer Science and Engineering		 #
# N.I.T.K., Surathkal				 		 #
# tahiliani.nitk@gmail.com					 #
# www.mohittahiliani.blogspot.com				 #
##################################################################

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     50                          ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      100                       ;# X dimension of topography
set val(y)      100                        ;# Y dimension of topography
set val(stop)   150.0                      ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open blackhole.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open blackhole.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      OFF \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 50 nodes

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns node]
	$node_($i) random-motion 1		;# disable random motion
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $node_($i) set X_ [expr rand()*250]
    $node_($i) set Y_ [expr rand()*250]
    $node_($i) set Z_ 0.0
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 20
}



# Node 5 is given RED Color and a label- indicating it is a Blackhole Attacker
$node_(5) color red
$ns at 0.0 "$node_(5) color red"
$ns at 0.0 "$node_(5) label Attacker"

# Node 0 is given GREEN Color and a label - acts as a Source Node
$node_(0) color green
$ns at 0.0 "$node_(0) color green"
$ns at 0.0 "$node_(0) label Source"

# Node 3 is given BLUE Color and a label- acts as a Destination Node
$node_(3) color blue
$ns at 0.0 "$node_(3) color blue"
$ns at 0.0 "$node_(3) label Destination"

#===================================
#    	Set node 5 as attacker    	 
#===================================
$ns at 0.0 "[$node_(6) set ragent_] hacker"

#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$ns attach-agent $node_(0) $udp0
set null1 [new Agent/Null]
$ns attach-agent $node_(3) $null1
$ns connect $udp0 $null1
$udp0 set packetSize_ 1000

#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ null
$ns at 1.0 "$cbr0 start"
$ns at 100.0 "$cbr0 stop"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam blackhole.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$node_($i) reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
