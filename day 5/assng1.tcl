set ns [new Simulator]

set tracefile_name [open assng1.tr w]
$ns trace-all $tracefile_name

set nam_out [open assng1.nam w]

$ns namtrace-all $nam_out

proc finish {} {
	global ns nam_out tracefile_name
	$ns flush-trace 
	#Close the trace file
	close $nam_out
	close $tracefile_name
	#Execute nam on the trace file
	exec nam assng1.nam & 	
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
	
$ns duplex-link $n0 $n1 10Mb 10ms DropTail

$ns queue-limit $n0 $n1 3

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.0003
$cbr0 attach-agent $udp0

$ns connect $udp0 $null0

$ns at 2.0 "$cbr0 start"
$ns at 10.0 "$cbr0 stop"

$ns at 11.0 "finish"

$ns run

