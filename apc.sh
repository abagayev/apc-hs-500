#!/bin/bash
# This script allows you to control APC BACK-UPS HS 500 from command line;
# Please install cURL before using; script works with web-interface of UPS;
# Options: [status] [output1=on,off,toggle,reboot] [output2=on,off,toggle,reboot] [output3=on,off,toggle,reboot]
# Copyright (c) 2011-2015 Anton Bagayev, abagayev@gmail.com, http://dontgiveafish.com

UPS="192.168.0.81"					# UPS IP
LOGIN="apc"						# UPS LOGIN
PASSWORD="55-55-55-55-55-55" 				# UPS PASSWORD (special code)
COOKIES="/tmp/apc-cookies.tmp"				# cookie temp file
CFG="/tmp/apc-cfg.tmp"					# temp file to get current configuration

# output aliases
# don't use symbol =
OUTPUT1="output1"
OUTPUT2="output2"
OUTPUT3="output3"

function onoffreboot {
# this function will help us to humanize statuses and options
# we use it this way: onoffreboot $1
# where $1 is number or humanized word  (for ex, 2=reboot)

        case "$1" in
	on)	echo 0;;
	off)	echo 1;;
	reboot)	echo 2;;
	0)	echo on;;
	1)	echo off;;
	2)	echo reboot;;
	toggle)	echo toggle;;
	esac

}

function outputvalue {
# this function will help us get to know current configuration
# use it this way: outputvalue $1 $2 
# where  $1 is filename, $2 is output var (for ex, q is var for output3)

	if [ $(grep -c "Checked..name=$2 value=0" $1) = 1 ]; then echo 0; fi
	if [ $(grep -c "Checked..name=$2 value=1" $1) = 1 ]; then echo 1; fi
	if [ $(grep -c "Checked..name=$2 value=2" $1) = 1 ]; then echo 2; fi
}

function toggle {
# this function will help us to toggle configuration
# use it this way: toggle $1
# where $1 is configuration(0 or 1)

        case "$1" in
	0)	echo 1;;
	1)	echo 0;;
	*)	echo $1;;
	esac
}

# parse options
# show help and exit if nothing
if [ -e $1 ]; then {
	echo "Options: [status] [$OUTPUT1=on|off|toggle|reboot] [$OUTPUT2=on|off|toggle|reboot] [$OUTPUT3=on|off|toggle|reboot]";
	exit;
}
fi

# parse query
for arg in "$@"; do
  case "$arg" in
	$OUTPUT1=*)		o1=$(onoffreboot `echo $arg | cut -d'=' -f2`);;
	$OUTPUT2=*)		o2=$(onoffreboot `echo $arg | cut -d'=' -f2`);;
	$OUTPUT3=*)		o3=$(onoffreboot `echo $arg | cut -d'=' -f2`);;

	status)			status=TRUE;;

  esac
done

# get output values from web-control
curl -sl "http://$UPS/CFG1.CGI" > $CFG

# get current values if empty query
if [ -e $o1 ]; then o1=$(outputvalue $CFG o); fi
if [ -e $o2 ]; then o2=$(outputvalue $CFG p); fi
if [ -e $o3 ]; then o3=$(outputvalue $CFG q); fi

# toggle values if toggle is in query
if [ $o1 == "toggle" ]; then o1=$(toggle $(outputvalue $CFG o)); fi
if [ $o2 == "toggle" ]; then o2=$(toggle $(outputvalue $CFG p)); fi
if [ $o3 == "toggle" ]; then o3=$(toggle $(outputvalue $CFG q)); fi

# show active configuration
if [ -n "$status" ]
	then echo "$OUTPUT1=$(onoffreboot $o1) $OUTPUT2=$(onoffreboot $o2) $OUTPUT3=$(onoffreboot $o3)"; fi

# aaaaand GO!
# login first
curl -slo /dev/null --cookie $COOKIES "http://$UPS/2?n=$LOGIN&T=$PASSWORD"
# install configuration
curl -slo /dev/null --cookie $COOKIES "http://$UPS/3?s=1&a=2&u=10&l=16&o=$o1&p=$o2&q=$o3&S2=Apply"
# logout
curl -slo /dev/null --cookie $COOKIES "http://$UPS/Logon.cgi"

# garbage collector
rm -f $CFG
rm -f $COOKIES