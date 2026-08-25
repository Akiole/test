#!/bin/sh

#set -x
set -e

ipset=${IPSET_BIN:-../src/ipset}

case "$1" in
    -4)
    	ip=10.0.
    	sep=.
    	net=32
    	ip2=192.168.162.33
    	;;
    -6)
    	ip=10::
    	sep=:
    	net=128
    	ip2=192:168::162:33
    	;;
esac

case "$2" in
    ip)
    	$ipset n test hash:ip $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y"
    	    done
    	done | $ipset restore
    	;;
    ipmark)
    	$ipset n test hash:ip,mark $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y,1023"
    	    done
    	done | $ipset restore
    	;;
    ipport)
    	$ipset n test hash:ip,port $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y,1023"
    	    done
    	done | $ipset restore
    	;;
    ipportip)
    	$ipset n test hash:ip,port,ip $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y,1023,$ip2"
    	    done
    	done | $ipset restore
    	;;
    ipportnet)
    	$ipset n test hash:ip,port,net $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y,1023,$ip2/$net"
    	    done
    	done | $ipset restore
    	;;
    netportnet)
    	$ipset n test hash:net,port,net $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 128`; do
    	    	echo "a test $ip$x$sep$y/$net,1023,$ip$y$sep$x/$net"
    	    done
    	done | $ipset restore
    	;;
    net)
    	$ipset n test hash:net $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y/$net"
    	    done
    	done | $ipset restore
    	;;
    netnet)
	$ipset n test hash:net,net $1 hashsize 64 timeout 100
	for x in `seq 0 16`; do
	    for y in `seq 0 255`; do
		echo "a test $ip$x$sep$y/$net,$ip$y$sep$x/$net"
	    done
	done | $ipset restore
	;;
    netport)
    	$ipset n test hash:net,port $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y/$net,1023"
    	    done
    	done | $ipset restore
    	;;
    netiface)
    	$ipset n test hash:net,iface $1 hashsize 64 timeout 100
    	for x in `seq 0 16`; do
    	    for y in `seq 0 255`; do
    	    	echo "a test $ip$x$sep$y/$net,eth0"
    	    done
    	done | $ipset restore
    	;;
esac
$ipset l test | grep ^$ip | while read x y z; do
    if [ $z -lt 10 -o $z -gt 100 ]; then
    	exit 1
    fi
done
$ipset x
exit 0
