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

if [ $JAVA_HOME ]
then
	JAVA_EXE=$JAVA_HOME/bin/java
fi

if [ $JAVA_HOME ]
then
	:
else
	for JAVA_EXE in `locate bin/java | grep java$ | xargs echo`
	do
		if [ $JAVA_HOME ] 
		then
			:
		else
			JAVA_HOME=`echo $JAVA_EXE | awk '{ print substr($1, 1, length($1)-9); }'`
		fi
	done
fi

 if [ $JAVA_HOME ]
      then
	BASEDIR=$(dirname $0)
	java -jar $BASEDIR"/WebScarab/webscarab.jar"
      else
             complain "Sorry, Java not installed."
 fi



