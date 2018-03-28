set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol

# =====================================================================
# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns [new Simulator]

set f [open four.tr w]
$ns trace-all $f
set nf [open four.nam w]
$ns namtrace-all-wireless $nf 670 670

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 700 700

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel.
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns node-config -adhocRouting $val(rp) \
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
             -macTrace OFF \
             -movementTrace OFF           
           
    for {set i 0} {$i < $val(nn) } {incr i} {
        set node_($i) [$ns node]   
        $node_($i) random-motion 0        ;# disable random motion
    }



#

#
# Define node movement model
#
puts "Loading connection pattern..."
#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0

#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
$ns at 50.0 "$node_(1) setdest 45.0 40.0 45.0"

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
   
    $ns initial_node_pos $node_($i) 40
}
set udp0 [new Agent/UDP]
$ns attach-agent $node_(0) $udp0

array set dbans {
    "how are you" "fine"
    "Are you there" "yes"
    "hi" "Thanks"       
    "" "Not Found"
}


set udp1 [new Agent/UDP]
$ns attach-agent $node_(1) $udp1

$ns connect $udp0 $udp1




# Setting the class allows us to color the packets in nam.
$udp0 set class_ 0
$udp1 set class_ 1

# The "process_data" instance procedure is what will process received data
# if no application is attached to the agent.
# In this case, we respond to messages of the form "ping(###)".
# We also print received messages to the trace file.

Agent/UDP instproc process_data {size data} {
    global ns
    global udp0
    global udp1
    global dbans
    $self instvar node_
   

   
    # note in the trace file that the packet was received
    $ns trace-annotate "[$node_ node-addr] received {$data}"
    set flag1 "0"
    set flag "0"
    foreach db [array names dbans] {
    set str3 [string equal $db $data]
   
    if {$str3 == "1"} {
    set flag "1"
   
    set str4 [$node_ node-addr]
    $ns trace-annotate "Replying correct question for recieved data:{$data}"
    $ns trace-annotate "question: $db answer: $dbans($db)"
    set ans "$dbans($db)"    
    switch $str4 {

        0 {$ns at 80 "$udp0 send 828 replied:$ans"}

        1 {$ns at 80 "$udp1 send 828 replied:$ans"}

        2 {$ns at 80 "$udp2 send 828 replied:$ans"}

        default {puts "I don't know what the number is"}

    }
    }
}
    set str5 [string equal $flag $flag1]
   
    if {$str5 == "1"} {
   
    $ns trace-annotate "Answer not found in database"
}

}

# Now, schedule some messages to be sent, using the UDP "send" procedure.
# The first argument is the length of the data and the second is the data
# itself.  Note that you can lie about the length, as we do here.  This allows
# you to send packets of whatever size you need in your simulation without
# actually generating a string of that length.  Also, note that the length
# you specify must not be larger than the maximum UDP packet size (the default
# is 1000 bytes)
# if the send procedure is called without a second argument (e.g. "send 100")
# then a packet of the specified length (or multiple packets, if the number
# is too high) will be sent, but without any data.  In that case, process_data
# will not be called at the receiver.


$ns at 50.3 "$udp0 send 500 {how are you}"

$ns at 70.5 "$udp1 send 828 hi"




#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns at 150.0 "$node_($i) reset";
}
$ns at 150.0 "stop"
$ns at 150.01 "puts \"NS EXITING...\" ; $ns halt"
proc stop {} {
       global ns f nf
    $ns flush-trace
    close $f
    close $nf

}

puts "Starting Simulation..."
$ns run

