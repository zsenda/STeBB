#!/bin/bash

packageExists () {
    type $1 > /dev/null
	if [ $? -eq 0 ]; then
		echo   -en "\nChecking for "$1"...\t\t- \033[32m[OK]\033[0m"
	else
		echo   -en "\nChecking for "$1"...\t\t- \033[31m[Not Found]\033[0m"
		echo   -en "\nInstalling " $1"...\t\t-  "
		progressInd &
		pid=$!
		trap "stopProgressInd $pid; exit" INT TERM EXIT

		sudo apt-get --yes --force-yes install $1 > /dev/null 

		if [ $? -eq 0 ]; then
			stopProgressInd $pid 
			echo -en "\b\033[32m[OK]\033[0m"
		else
			stopProgressInd $pid 
			echo -en "\b\033[31m[Installation Errored. Please install $1 manually]\033[0m"	
		fi	
	fi
}

pythonExists () {

    type python > /dev/null
	if [ $? -eq 0 ]; then
		echo   -en "\nChecking for python...\t\t- \033[32m[OK]\033[0m"
		echo   -en "\nChecking py modules...\t\t-  "
		progressInd &
		pid=$!
		trap "stopProgressInd $pid; exit" INT TERM EXIT

		sudo apt-get --yes --force-yes install python-pycurl > /dev/null
		sudo apt-get --yes --force-yes install python-qt4 > /dev/null

		if [ $? -eq 0 ]; then
			stopProgressInd $pid 
			echo -en "\b\033[32m[OK]\033[0m"
		else
			stopProgressInd $pid 
			echo -en "\b\033[31m[Installation Errored. Please install python-pycurl and python-qt4 manually]\033[0m"		
		fi			 	
	else
		echo   -en "\nChecking for python...\t\t- \033[31m[Not Found]\033[0m"
		echo   -en "\nInstalling python ...\t\t-  "
		progressInd &
		pid=$!
		trap "stopProgressInd $pid; exit" INT TERM EXIT

		sudo apt-get --yes --force-yes install python > /dev/null

		if [ $? -eq 0 ]; then
			stopProgressInd $pid 
			echo -en "\b\033[32m[OK]\033[0m"
		else
			stopProgressInd $pid 
			echo -en "\b\033[31m[Installation Errored. Please install python manually]\033[0m"
		fi	

		echo   -e "Installing python packages...\t\t-  "
		progressInd &
		pid=$!
		trap "stopProgressInd $pid; exit" INT TERM EXIT

		sudo apt-get --yes --force-yes install python-pycurl > /dev/null
		sudo apt-get --yes --force-yes install python-qt4 > /dev/null
		
		if [ $? -eq 0 ]; then
			stopProgressInd $pid 
			echo -en "\b\033[32m[OK]\033[0m"
		else
			stopProgressInd $pid 
			echo -en "\b\033[31m[Installation Errored. Please install python-pycurl and python-qt4 manually]\033[0m"	
		fi	
	fi

}

javaExists () {
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
				  echo  -en "\nChecking for Java...\t\t- \033[32m[OK]\033[0m"
		  else
				  echo  -en "\nChecking for Java...\t\t- \033[31m[Not Found]\033[0m"
				  echo  -en "\033[0m"
				  echo -e "\033[31m[Please install Java manually]\033[0m"	
	 fi
}

progressInd () {
  chars=( "-" "\\" "|" "/" )
  interval=.1
  count=0
  while true
  do
    pos=$(($count % 4))	
    echo   -en "\b${chars[$pos]}"
    count=$(($count + 1))
    sleep $interval
  done
}

#
# Stop progress indicator
#
stopProgressInd () {
  exec 2>/dev/null
  kill $1

}

#first sudo 
sudo cp  STeBB.png /usr/share/icons 
sudoExitCode=$?
		if [ $sudoExitCode -eq 0 ]; then
			:
		elif [ $sudoExitCode -eq 1 ];then 	
			echo -en "\b\033[31m[Incorrect sudo password provided. Exiting Installation]\033[0m\n"
			exit		
		else
			echo -en "\b\033[31m[Something went wrong. Exiting Installation]\033[0m\n"
			exit	
		fi	
#copying starts here.
echo  -en "Installing STeBB Core...\t\t-  "

progressInd &
pid=$!
trap "stopProgressInd $pid; exit" INT TERM EXIT

sudo cp -fR STeBB /usr/share 
sudo cp  uninstallSTeBB /usr/share/STeBB
sudo chmod 755 -R /usr/share/STeBB/
sudo ln -sf /usr/share/STeBB/stebb /usr/bin/stebb

cp -fR .stebb $HOME 

stopProgressInd $pid 
echo -en "\b\033[32m[OK]\033[0m"

profilename=$(</dev/urandom tr -dc '[:alnum:]' | head -c ${1:-8} 2>&1)
mv $HOME/.stebb/stebb/stebb.default $HOME/.stebb/stebb/$profilename.default
sed -i "s/stebb.default/$profilename.default/" $HOME/.stebb/stebb/profiles.ini


pythonExists 
packageExists perl
javaExists
packageExists gnome-nettool
packageExists gnome-schedule
packageExists gnome-screenshot
packageExists gnome-system-log
packageExists gnome-system-monitor
packageExists gnome-control-center



echo  -e "\n"
echo  -en "Configuring STeBB Files...\t\t-  "

progressInd &
pid=$!
trap "stopProgressInd $pid; exit" INT TERM EXIT

cat <<EOF >$HOME/Desktop/stebb.desktop
[Desktop Entry]
Encoding=UTF-8
Name=STeBB
GenericName=STeBB
Exec=stebb
Terminal=false
Icon=STeBB.png
Type=Application
Categories=Application;Network;Security
Comment=Security Testing Browser Bundle
StartupNotify=true
EOF


chmod 755 $HOME/Desktop/stebb.desktop

sudo cp $HOME/Desktop/stebb.desktop /usr/share/applications/
sudo chmod 755 /usr/share/applications/stebb.desktop

cat <<EOF >$HOME/.stebb/Vidalia/vidalia.conf
[General]
BrowserDirectory=/
BrowserExecutable=usr/share/STeBB/stebb
InterfaceStyle=Cleanlooks
LanguageCode=en
ProfileDirectory=$HOME/.stebb/stebb/tor.profile
DefaultProfileDirectory=$HOME/.stebb/stebb/tor.profile
PluginsDirectory=$HOME/.stebb/stebb/tor.profile/extensions
DefaultPluginsDirectory=$HOME/.stebb/stebb/tor.profile/extensions
ShowMainWindowAtStart=true

[Tor]
ControlPort=9051
TorExecutable=./tor
Torrc=$HOME/.stebb/Tor/torrc
AutoControl=true
DataDirectory=$HOME/.stebb/Tor

[MessageLog]
Geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x2\xb9\0\0\x2p\0\0\0\0\0\0\0\0\0\0\x2\xb9\0\0\x2p\0\0\0\0\0\0)

[BandwidthGraph]
Geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x2(\0\0\x1X\0\0\0\0\0\0\0\0\0\0\x2(\0\0\x1X\0\0\0\0\0\0)

[NetViewer]
Geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x3K\0\0\x2S\0\0\0\0\0\0\0\0\0\0\x3K\0\0\x2S\0\0\0\0\0\0)

[ConfigDialog]
Geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x2W\0\0\x1\x8f\0\0\0\0\0\0\0\0\0\0\x2W\0\0\x1\x8f\0\0\0\0\0\0)

[MainWindow]
Geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\0\0)
EOF

cat <<EOF >$HOME/.stebb/Tor/torrc
# If non-zero, try to write to disk less frequently than we would otherwise.
AvoidDiskWrites 1
# Store working data, state, keys, and caches here.
DataDirectory $HOME/.stebb/Tor
GeoIPFile $HOME/.stebb/Tor/geoip
# Where to send logging messages.  Format is minSeverity[-maxSeverity]
# (stderr|stdout|syslog|file FILENAME).
Log notice stdout
# Bind to this address to listen to connections from SOCKS-speaking
# applications.
SocksPort auto
SocksListenAddress 127.0.0.1
ControlPort auto
EOF

stopProgressInd $pid 
echo -en "\b\033[32m[OK]\033[0m"
echo -en "\n"

 echo  -e "\033[31m"
 echo  " _____ _____   ____________ "
 echo  "/  ___|_   _|  | ___ \ ___ \\"
 echo  "\ `--.  | | ___| |_/ / |_/ /"
 echo  " `--. \ | |/ _ \ ___ \ ___ \\"
 echo  "/\__/ / | |  __/ |_/ / |_/ /"
 echo  "\____/  \_/\___\____/\____/ "
                                                                                                                                                                                                                           
 echo  -e "\033[0m"      
 echo  -e "\033[32m" 
 echo  "#########################################################"
 echo  "#                                                       #"
 echo  "#    With great powers comes great responsibilities.    #"
 echo  "#    Be careful what you do with it.                    #"
 echo  "#                                                       #"
 echo  "#########################################################"
 echo  -e "\033[0m"   

           
