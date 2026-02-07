#!/bin/bash

# Internal IP
IP=$(hostname -i | awk {'print $1}')

# Packet loss check
timeout 7s ping -c 5 google.com | grep 'loss' | awk '{print $6}' > /dev/null 2>&1
if [[ $? -eq 0 ]]
    then
        PL=$(ping -c 5 google.com | grep 'loss' | awk '{print $6}')
        PL+=" p/l"
    else
        PL=""
fi

# Speedtest
SPEEDTEST=$(speedtest-go --unix 2>&1)
DL=$(echo "$SPEEDTEST" | grep '^Download:' | awk '{print $2}')
UP=$(echo "$SPEEDTEST" | grep '^Upload:' | awk '{print $2}')

# PUBLIC_IP=$(curl -4 ifconfig.co)
#
# if [[ "$PUBLIC_IP" = ";; connection timed out; no servers could be reached" ]]; then
#     PUBLIC_IP="Not Available"
# elif [[ "$PUBLIC_IP" = "" ]]; then
#     PUBLIC_IP="No external access"
# else
#     PUBLIC_IP=$(curl -4 ifconfig.co)
# fi

INTERNET=''

#internet_info=`iwconfig eth0 | grep "Signal level" | awk '{print $2}' | sed 's/-//g'`

# if [[ $internet_info -lt 20 ]]; then
#     echo -n '#[fg=colour150]'
# elif [[ $internet_info -lt 30 ]]; then
#     echo -n '#[fg=colour155]'
# elif [[ $internet_info -lt 40 ]]; then
#     echo -n '#[fg=colour160]'
# elif [[ $internet_info -lt 50 ]]; then
#     echo -n '#[fg=colour163]'
# else
#     echo -n '#[fg=colour150]'
# fi

echo -n "#[fg=#a6d189]$INTERNET #[fg=#81c8be]⏬$DL M/s ⏫$UP M/s #[fg=#ca9ee6]$IP | $PL"
