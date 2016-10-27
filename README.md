# softether-vpn-scripts

## Usage:
```
start-wrapper.sh -h HOST -a ACCOUNT -i INTERFACE
    program starts vpn client, connects to selected account and add static route

where:
    -h|--host       host server, server ip need to be add into routes
    -a|--account    name of vpnclient account
    -i|--interface  name of vpn tun interface
    --help          print this message
    --vpnclient     path to vpnclient (default ./vpnclient)
    --vpncmd        path to vpnclient (default ./vpnclient)
```
