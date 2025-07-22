
SSID=$(nmcli -t -f SSID dev wifi list | grep -v "^$" | uniq | rofi -dmenu -p "WiFi SSID")

if [ -z "$SSID" ]; then
    exit 0
fi

# Try to connect (will ask for password if needed)
nmcli dev wifi connect "$SSID" || rofi -e "Connection Failed"

