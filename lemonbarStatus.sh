#!/bin/sh

clock() {
  date +%a\ %b\ %d\ %H:%M
}

battery() {
  BAT1="/sys/class/power_supply/BAT1/"
  capacity=$(cat /sys/class/power_supply/BAT1/capacity)
  status=$(cat /sys/class/power_supply/BAT1/status)   
  
  if [ "$capacity" -gt 99 ]
  then
    output="%{F#00ff00} \uf240 $capacity %{F-}"
  elif [ "$status" = "Charging" ]
  then
    output="\uf1e6 $capacity"
  elif [ "$capacity" -lt 20 ]
  then
    output="%{F#ff0000} \uf242 $capacity  %{F-}"
  else
    output="\uf242 $capacity"
  fi
  echo $output
}

volume() {
 info=$(amixer get Master| grep "Front Left: Playback")
 sound=$(echo "$info"| cut -d " " -f 8)
 if [ "$sound" = "[off]" ]
 then
    echo  "\uf6a9 0%"
 else
  level=$(echo "$info" | cut -d " "  -f 7 | sed  's/\[\|\]//g')
  echo "\uf028 "$level
 fi
}

workspaces(){
  all=$(xprop -root _NET_DESKTOP_NAMES| awk '{$1=$2="";print $0}'| sed -e 's/ //g' -e 's/"//g' -e 's/,/ /g')
  index=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
  current=$(echo $all| cut -d " " -f$(($index+1)))
  echo $all| sed -e  "s/$current/%{R} $current %{R}/"   
} 

music() {
 if [ $(pgrep mpd) ]
 then 
  mpc current 2> /dev/null
 fi
}

while true
do
  status="%{l} $(workspaces) %{r} $(music) $(volume) | $(battery) | $(clock)"
  echo -e "$status"
sleep 0.4
done | lemonbar   -p -u 5 -f "Inconsolata"-12 -B "#232323" -F "#DCD8D0" -f "Font Awesome 5 Brands Regular" -f "Font Awesome 5 Free Solid" -f "Font Awesome 5 Free Regular"

