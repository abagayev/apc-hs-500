#Another way to manage your APC BACK-UPS HS 500

APC BACK-UPS HS 500 is a nice UPS with remote control via web. It has three sockets and you can set them on, off or reboot with web-interface.

So, I created a script to do it simply from the command line. You can use it in small networks for rebooting remote devices, or anything you can imagine, for example, making toasts :-)

Please install cURL before using(script works with web-interface of UPS).

Run it with options: 
./apc.sh [--status] [--output1=on,off,reboot] [--output2=on,off,reboot] [--output3=on,off,reboot]

This was developed at dontgiveafish.com by Anton Bagayev in 2011