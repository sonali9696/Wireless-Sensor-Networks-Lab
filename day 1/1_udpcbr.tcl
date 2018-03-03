set ns [new Simulator] 
#initialization, "new" keyword, class "Simulator". Object created

#open trace file declaration
set traceFile1 [open out.tr w]
$ns trace-all $traceFile1

#NAM trace file declaration
set nf1 [open out.nam w]
$ns namtrace-all $nf1

proc finish {} {
	global ns traceFile1 nf1
	$ns flush-trace
	close $traceFile1
	close $nf1
	exec nam out.nam &
	exit 0
}

#create 2 nodes
set n0 [$ns node]
set n1 [$ns node]

#duplex link between the nodes (so ack received)
$ns duplex-link $n0 $n1 10Mb 10ms DropTail

$ns queue-limit $n0 $n1 20

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.0002

$ns connect $udp0 $null0

$ns at 2.0 "$cbr0 start"
$ns at 10.0 "$cbr0 stop"

$ns at 11.0 "finish"
$ns run

