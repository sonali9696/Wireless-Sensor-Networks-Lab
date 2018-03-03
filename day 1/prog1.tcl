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



