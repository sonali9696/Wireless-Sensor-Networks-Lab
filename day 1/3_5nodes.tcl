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
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns simplex-link $n2 $n3 300Kb 100ms DropTail
$ns simplex-link $n3 $n2 300Kb 100ms DropTail
$ns duplex-link $n4 $n3 500Kb 40ms DropTail
$ns duplex-link $n5 $n3 500Kb 30ms DropTail

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.0003

$ns at 2.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"
$ns at 3.0 "$cbr0 start"
$ns at 9.0 "$cbr0 stop"

$ns at 11.0 "finish"
$ns run

