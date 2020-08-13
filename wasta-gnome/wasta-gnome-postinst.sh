#!/bin/bash

# ==============================================================================
# wasta-gnome-postinst.sh
#
#   This script is automatically run by the postinst configure step on
#       installation of wasta-gnome-*. It can be manually re-run, but
#       is only intended to be run at package installation.
#
#   2020-07-22 ndm: initial script
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Check to ensure running as root
# ------------------------------------------------------------------------------
#   No fancy "double click" here because normal user should never need to run
if [ $(id -u) -ne 0 ]
then
	echo
	echo "You must run this script with sudo." >&2
	echo "Exiting...."
	sleep 5s
	exit 1
fi

# ------------------------------------------------------------------------------
# Initial setup
# ------------------------------------------------------------------------------

echo
echo "*** Script Entry: wasta-gnome-postinst.sh"
echo

# Setup Directory for later reference
DIR=/usr/share/wasta-gnome

# ------------------------------------------------------------------------------
# General initial config
# ------------------------------------------------------------------------------
# Add Wasta icon to slick-greeter desktop entry.
cp -l /usr/share/wasta-multidesktop/resources/wl-round-22.png /usr/share/slick-greeter/badges/wasta-gnome.png

# Disable gnome-screensaver by default (re-enabled at wasta-gnome session login).
if [[ -e /usr/share/dbus-1/services/org.gnome.ScreenSaver.service ]]; then
    mv /usr/share/dbus-1/services/org.gnome.ScreenSaver.service{,.disabled}
fi

# ------------------------------------------------------------------------------
# Dconf / Gsettings Default Value adjustments
# ------------------------------------------------------------------------------
echo
echo "*** Updating dconf / gsettings default values"
echo

# Updating dconf before GNOME schemas because they depend on its entries.
dconf update

# GNOME Extension schemas: separate locations from System schemas.
glib-compile-schemas /usr/share/gnome-shell/extensions/applications-overview-tooltip@RaphaelRochet/schemas/ > /dev/null 2>&1 || true;

glib-compile-schemas /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ > /dev/null 2>&1 || true;

glib-compile-schemas /usr/share/gnome-shell/extensions/panel-osd@berend.de.schouwer.gmail.com/schemas/ > /dev/null 2>&1 || true;

# MAIN System schemas: we have placed our override file in this directory
# Sending any "error" to null (if key not found don't want to worry user)
glib-compile-schemas /usr/share/glib-2.0/schemas/ > /dev/null 2>&1 || true;

echo
echo "*** Restarting GNOME Shell"
echo
killall -SIGQUIT gnome-shell

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------
echo
echo "*** Script Exit: wasta-gnome-postinst.sh"
echo

exit 0
