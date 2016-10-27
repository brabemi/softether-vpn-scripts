#!/bin/bash

VPNCLIENT=./vpnclient
VPNCMD=./vpncmd
INTERFACE=vpn_vpn #default name

USAGE="$(basename "$0") -h HOST -a ACCOUNT -i INTERFACE
    program starts vpn client, connects to selected account and add static route

where:
    -h|--host       host server, server ip need to be add into routes
    -a|--account    name of vpnclient account
    -i|--interface  name of vpn tun interface
    --help          print this message
    --vpnclient     path to vpnclient (default ./vpnclient)
    --vpncmd        path to vpnclient (default ./vpnclient)
    "

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -h|--host)
    HOST="$2"
    shift
    ;;
    -a|--account)
    ACCOUNT="$2"
    shift
    ;;
    -i|--interface)
    INTERFACE="$2"
    shift
    ;;
    --vpnclient)
    VPNCLIENT="$2"
    shift
    ;;
    --vpncmd)
    VPNCMD="$2"
    shift
    ;;
    --vpncmd)
    VPNCMD="$2"
    shift
    ;;
    --help|*)
    echo "$USAGE"
    exit
    ;;
esac
shift
done

if [ -z "$HOST" -o -z "$INTERFACE" -o -z "$ACCOUNT" -o -z "$VPNCLIENT" -o -z "$VPNCMD" ]; then
    echo "$USAGE"
    exit 1
fi

echo "Starting $VPNCLIENT"
sudo $VPNCLIENT start 1> /dev/null

if [ $? != 0 ]; then
  echo "Unable to start vpnclient, command: sudo $VPNCLIENT start"
  exit 1
fi

echo "Getting default route"
DATA=$(ip route| grep default | head -n 1 | awk '/default/ { print $3,$5 }')
if [ $? != 0 ]; then
  echo "Unable to get default route ip a device"
  exit 1
fi
IP=$(echo $DATA | awk '{ print $1 }')
DEV=$(echo $DATA | awk '{ print $2 }')

if [[ $HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
  DEST=$HOST
else
  echo "Getting server ip address"
  DEST=$(dig +short $HOST)
  if [ $? != 0 ]; then
    echo "Unable to get $HOST ip address, command: dig +short $HOST"
    exit 1
  fi
fi

echo "Activating account $ACCOUNT"
$VPNCMD localhost /client /cmd accountconnect $ACCOUNT 1> /dev/null
if [ $? != 0 ]; then
  echo "Unable to active account $ACCOUNT"
  exit 1
fi

echo "starting dhclient on interface $INTERFACE"
sudo dhclient -r $INTERFACE 1> /dev/null
sudo dhclient $INTERFACE 1> /dev/null
if [ $? != 0 ]; then
  echo "Unable to active dhclient on interface $INTERFACE"
  exit 1
fi

echo "Adding route to $DEST via $IP dev $DEV"
sudo ip route add $DEST via $IP dev $DEV proto static  metric 600 1> /dev/null
if [ $? != 0 ]; then
  echo "Unable to route to $DEST"
  exit 1
fi
