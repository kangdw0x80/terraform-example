#! /bin/bash
touch testfile
date >> /tmp/echotest
echo "userdata">> /tmp/echotest
chmod 777 /tmp/echotest
whoami >> /tmp/echotest
pwd >> /tmp/echotest
pwd >> /log.txt
netstat -nltp >> /log.txt
netstat -nltp >> /tmp/echotest
lastlog >> /log.txt
lastlog >> /tmp/echotest
who >>/root/log.txt
who >>/tmp/echotest
