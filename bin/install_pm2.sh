#!/bin/sh

PROG_NAME='pm2'
PROG_VERSION=5.1.2
HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`
# Version should increment up if a script should perform an update to current installs. (int)
INSTALL_SCRIPT_VERSION=1

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`

nodejsDir=$topDir/nodejs/$HOST_ARCH
installDir=$topDir/nodejs
fullInstallDir=$nodejsDir/lib/node_modules/$PROG_NAME
INSTALL_SCRIPT_VERSION_PATH=$fullInstallDir/installScriptVersion

if [ ! -d $installDir ]; then
    echo "$installDir does not exist, try to run install_nodejs.sh first"
    exit 1
fi

if [ -d $fullInstallDir ]; then
	if [ $INSTALL_SCRIPT_VERSION -gt `cat $INSTALL_SCRIPT_VERSION_PATH` ]; then 
		echo "$PROG_NAME needs to be updated"
	elif [ "x$1" == "x--force" ]; then 
    	echo "[WARNING] It appears that $PROG_NAME is already installed." >&2
    	echo "Would you like to remove the current installation of $PROG_NAME at $fullInstallDir"
		read -p "Remove and Continue (y/n)? " response
		case "$response" in 
		y|Y ) 
			echo "Removal confirmed: $fullInstallDir";;
		n|N )
			exit 1;;
		* ) 
			echo "Invalid response, $PROG_NAME will not be installed"
			exit 1;;
		esac
	else 
		echo "$PROG_NAME is already installed with the latest script"
		if [ ! x$1 == "x--silent" ]; then 
			echo "Running the install script with the switch --force to override install"
		fi
		exit 1
	fi	
else 
	echo "$PROG_NAME needs to be installed"
fi 

if [ x$1 == "x--silent" ]; then 
	exit 0
else
	echo "removing directory $fullInstallDir"
	rm -Rf $fullInstallDir
fi

$nodejsDir/bin/npm -g install $PROG_NAME@$PROG_VERSION || exit 1 

echo "$PROG_NAME has been installed in $fullInstallDir"
echo $INSTALL_SCRIPT_VERSION > $INSTALL_SCRIPT_VERSION_PATH

cd $currentDir
