#!/bin/sh
complain () {
	# Trim leading newlines, to avoid breaking formatting in some dialogs.
	complain_message="`echo "$1" | sed '/./,$!d'`"

	# If we're being run in a terminal, complain there.
	if [ "$ARE_WE_RUNNING_IN_A_TERMINAL" -ne 0 ]; then
		echo "$complain_message" >&2
		return
	fi

	# Otherwise, we're being run by a GUI program of some sort;
	# try to pop up a message in the GUI in the nicest way
	# possible.
	#
	# In mksh, non-existent commands return 127; I'll assume all
	# other shells set the same exit code if they can't run a
	# command.  (xmessage returns 1 if the user clicks the WM
	# close button, so we do need to look at the exact exit code,
	# not just assume the command failed to display a message if
	# it returns non-zero.)

	# First, try zenity.
	zenity --error \
		--title="$complain_dialog_title" \
		--text="$complain_message"
	if [ "$?" -ne 127 ]; then
		return
	fi

	# Try kdialog.
	kdialog --title "$complain_dialog_title" \
		--error "$complain_message"
	if [ "$?" -ne 127 ]; then
		return
	fi

	# Try xmessage.
	xmessage -title "$complain_dialog_title" \
		-center \
		-buttons OK \
		-default OK \
		-xrm '*message.scrollVertical: Never' \
		"$complain_message"
	if [ "$?" -ne 127 ]; then
		return
	fi

	# Try gxmessage.  This one isn't installed by default on
	# Debian with the default GNOME installation, so it seems to
	# be the least likely program to have available, but it might
	# be used by one of the 'lightweight' Gtk-based desktop
	# environments.
	gxmessage -title "$complain_dialog_title" \
		-center \
		-buttons GTK_STOCK_OK \
		-default OK \
		"$complain_message"
	if [ "$?" -ne 127 ]; then
		return
	fi
}
type perl > /dev/null
		if [ $? -eq 0 ]; then

			BASEDIR=$(dirname $0)
			CDATE=$(date +%Y%m%d_%H%M%S)
			echo $1 >> niktoLog.txt
			$1 > $HOME/.stebb/nikto_results/niktoscan$CDATE.txt &
			gnome-terminal -e "tail -f --retry $HOME/.stebb/nikto_results/niktoscan$CDATE.txt" > /dev/null

		else
			complain "Sorry,  perl not installed."
		fi
