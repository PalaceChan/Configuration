#!/bin/sh

#Remeber to make a custom.desktop in /usr/share/xsessions/custom.desktop with contents as below to get the login optionality
#also make a home symlink .xsession -> .xinitrc
#[Desktop Entry]
#Name=Xsession
#Exec=/etc/X11/Xsession

# Disable access control
xhost +SI:localuser:$USER

# Set themes, etc.
gnome-settings-daemon &

# Set fallback cursor.
xsetroot -cursor_name left_ptr

# Set keyboard repeat rate.
xset r rate 200 60

#EXWM
exec dbus-launch --exit-with-session /usr/bin/emacs25
