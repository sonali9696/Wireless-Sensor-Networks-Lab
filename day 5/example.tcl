set ns [new Simulator]

set tracefile_name [open example.tr w]
$ns trace-all $tracefile_name

set nam_out [open example.nam w]

$ns namtrace-all $nam_out

proc finish {} {
	global ns nam_out tracefile_name
	$ns flush-trace 
	#Close the trace file
	close $nam_out
	close $tracefile_name
	#Execute nam on the trace file
	exec nam example.nam & 	
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
	
$ns duplex-link $n0 $n1 10Mb 10ms DropTail

$ns queue-limit $n0 $n1 20

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 2.0 "$ftp start"
$ns at 10.0 "$ftp stop"

$ns at 11.0 "finish"

$ns run

