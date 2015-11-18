# Another way to manage your APC BACK-UPS HS 500

![](https://raw.githubusercontent.com/abagayev/apc-hs-500/master/hs500.jpg)

APC BACK-UPS HS 500 is a nice UPS with remote control via web. It has three sockets and you can set them on, off or reboot with web-interface.

So, I created a script to do it simply from the command line. You can use it in small networks for rebooting remote devices, or anything you can imagine, for example, making toasts :-)

### How to config

Please install cURL before using(script works with web-interface of UPS):

```shell
sudo apt-get install curl
```

Change config in shell file - set IP of your device, login and encrypted password. You can encrypt password with [webtool](http://htmlpreview.github.io/?https://raw.githubusercontent.com/abagayev/apc-hs-500/master/passwordgenerator.html) in this project.

```shell
UPS="192.168.0.81"
LOGIN="apc"
PASSWORD="55-55-55-55-55-55"
```

Also, you can add aliases to inputs to make work with script more comfortable

```shell
OUTPUT1="router"
OUTPUT2="server"
OUTPUT3="coffeemachine"
```

### How to use

Run it with options: 

```shell
# This is how you can call your device via shell:
./apc.sh [--status] [--output1=on,off,reboot] [--output2=on,off,reboot] [--output3=on,off,reboot]

# This will output statuses of outputs
./apc.sh --status

# This will reboot device out output1
./apc.sh --output1=reboot

# This will reboot server and turn on coffemachine(if you are using aliases)
./apc.sh --server=reboot --coffemachine=on
```

### Be awared!

* Use only letters in password, details on [APC Discussion Forums](http://www.apc-forums.com/thread.jspa?threadID=4563&start=0&tstart=0)
* Use Back-UPS HS v1.0.0 Management Tool to assign IP address to your UPS. Unfortunately, it works with Windows 98-XP only, and i don't know if there are possible ways to assign IP via linux/macos/anything else

### Another example of using

I use this script to switch routers of internet providers with not stable internet connection. This is how I do this:

```shell
# Site to ping
SITE="8.8.8.8"
# Count of packets to send
PINGCOUNT=10

# This will give count of received packets
RECEIVED=`ping -qc $PINGCOUNT $SITE | tail -n 2 | head -n 1 | awk '/[0-9]/ { print $4 }'`

# Now you devide what to do, if all/not all/zero packets received
if [[ -z $RECEIVED ]] || [[ $RECEIVED == "0" ]]; then {
	echo "No internet connection, switching";
	./apc.sh inet1=toggle inet2=toggle
}
elif [[ $RECEIVED -eq $PINGCOUNT ]]; then
	echo "Internet connection is stable.";
else
	echo "Internet connection is unstable, `echo "100*$RECEIVED/$PINGCOUNT" | bc`% packet loss.";
fi
```

Just add this script to cron and you will have good internet connection every day :-)

### Copyright

This was developed at dontgiveafish.com by Anton Bagayev in 2011
