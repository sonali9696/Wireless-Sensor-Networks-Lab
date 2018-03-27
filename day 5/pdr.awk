BEGIN {
	sendLine = 0;
	recvLine = 0;
	dropLine = 0;
	
	AGTline=0;
	RTRline=0;
	
	simulationTime=100;
}

$0 ~/^r.* cbr/ {
	recvLine ++ ;
}

$0 ~/^s.* cbr/ {
	sendLine ++ ;
}

$0 ~/^d.* cbr/ {
	dropLine ++ ;
}

$0 ~/^r.* AGT/ {
	AGTline ++ ;
}

$0 ~/^r.* RTR/ {
	RTRline ++ ;
}


END {
	printf "Throughput:%.4f \n", ((recvLine*8)/simulationTime);
	printf "Dropped:%.4f \n", (dropLine);
	printf "Normalized:%.4f \n", (RTRline/AGTline);
}
