#!/bin/sh

BG="#121212"
FG="#d9d9d9"
FONT="M+1mn:size=8" # "-*-terminus-medium-r-*-*-10-*-*-*-*-*-iso10646-*"

BAR_OPS="-fg #d9d9d9 -bg #555555 -h 7 -w 25 -s o -ss 1 -sw 2"

# Icons
ICONS_PATH="$HOME/.xmonad/dzen_icons" # path to icons directory
CLOCK="$ICONS_PATH/clock.xbm"
VOL="$ICONS_PATH/spkr_01.xbm"
CPU="$ICONS_PATH/cpu.xbm"
MEM_ICO="$ICONS_PATH/mem.xbm"

NOW_PLAYING_FORMAT="%a - %t"

#colors
blue="#3399ff"
gray="#121212"

# spacing
space(){
	echo "^fn($FONT)^fg(#555555) | ^fg()^fn()"
}

# shows current keyboard layout
# left click to change layout to us -> ua -> ru -> us ...
layout(){
	LAYOUT=$(setxkbmap -query | awk 'END{print $2}')
	#shows current keyboard layout
	#changes layout whel clicked
	echo -n "^ca(1, $HOME/scripts/layout_switch.sh)^fg()$LAYOUT^fg()^ca()"
}

# shows current system load
load() {
	cpu=$(bc <<< $(ps -eo pcpu |grep -vE '^\s*(0.0|%CPU)' |sed -n '1h;$!H;$g;s/\n/ +/gp'))
	#cpu=$($HOME/scripts/cpu_usage.sh)
	echo -ne "^fg($blue)^i($CPU) ^fg()$cpu%"
}

# shows RAM usage in format used_ram / total_ram MB
mem(){
	MEM=$(free -m | grep Mem: '-' | awk '{print $3,"/",$2}')
	echo -n "^fg($blue)^i($MEM_ICO) ^fg()${MEM} MB"
	return
}

# shows current music, playing in ncmpcpp
# right click to play/pause ncmpcpp
# scroll up to change to next song in playlist
# scroll down to change to previous song in playlist
music(){
	playing=$(mpc current)
	echo -n "^ca(3, mpc toggle)^ca(4, mpc next)^ca(5, mpc prev)^fg($blue)[^fg()$playing^fg($blue)]^ca()^ca()^ca()"
}

# shows volume bar
# scroll up to increase volume
# scroll downto decrease volume
vol(){
	ismute=`amixer get Master|grep %|awk '{ print $6 }'|sed 's/\[//g'|sed 's/\]//g'`
	if [ "$ismute" == "off" ]; then
		VBS="0"
	else
		VBS=`amixer get Master|grep %|awk '{ print $4 }'|sed 's/%//g'|sed 's/\[//g'|sed 's/\]//g'`
	fi	
	
	VBAR=`echo "$VBS" | gdbar $BAR_OPS |awk '{ print $1 }'`
	echo "^ca(4, amixer set Master 2dB+)^ca(5, amixer set Master 2dB-)^fg($blue)^i($VOL) ^fg()$VBAR ^ca()^ca()"
}

# shows current date and time
dateTime(){
	DATE=`date +"%d %b %A,"`
	TIME=`date +"%I:%M:%S"`
	#CALENDAR=cal | dzen2 -x 1240 -w 200 -h 150 -e 'onstart=uncollapse;button1=exit;button3=exit'
	echo "^ca(1, $HOME/scripts/calendar.sh)^fg($blue)^i($CLOCK) ^fg()$DATE $TIME^ca()"
}

while true ; do
	echo $(space)$(layout)$(space)$(load) $(mem)$(space)$(vol)$(music)$(space)$(dateTime)$(space)	
done | dzen2 -p -x 740 -w 700 -h 20 -ta 'r' -fg $FG -bg $BG -fn "$FONT" -e 'button1=exec:xterm; button2=;' 