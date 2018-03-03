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

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n0 $n2 1Mb 10ms DropTail

$ns queue-limit $n0 $n1 20
$ns queue-limit $n0 $n2 20

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $sink0
$ns connect $tcp0 $sink0

set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink1
$ns connect $tcp1 $sink1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 2.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

$ns at 2.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

$ns at 11.0 "finish"
$ns run

