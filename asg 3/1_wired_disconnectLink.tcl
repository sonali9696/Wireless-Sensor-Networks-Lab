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
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n1 0.3Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.3Mb 10ms DropTail
$ns duplex-link $n4 $n1 0.3Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.3Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.3Mb 10ms DropTail
$ns duplex-link $n3 $n5 0.3Mb 10ms DropTail

$ns queue-limit $n0 $n1 20

$ns rtmodel-at 1.0 down $n1 $n4
$ns rtmodel-at 4.5 up $n1 $n4

$ns rtproto DV

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n5 $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

$ns at 0.1 "$ftp0 start"
$ns at 12.0 "$ftp0 stop"

$ns at 11.0 "finish"
$ns run

