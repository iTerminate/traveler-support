#!/bin/bash

# Check linux distriubtions 
if [ `uname` = "Linux" ]; then
	if [ -f /etc/centos-release ]; then 
		CENTOS_RELEASE=`cat /etc/centos-release`

		if [[ $CENTOS_RELEASE == *"release 8"* ]]; then
			CODENAME="Ootpa"
		elif [[ $CENTOS_RELEASE == *"release 7"* ]]; then
			CODENAME="Maipo"
		elif [[ $CENTOS_RELEASE == *"release 6"* ]]; then
			CODENAME="Santiago"
		fi
	else
    	CODENAME=`lsb_release -sc`
	fi 

	# RHEL 6
    if [ $CODENAME = "Santiago" ]; then
		MONGO_DB_VERSION=rhel62-4.2.6
	# RHEL 7
	elif [ $CODENAME = "Maipo" ]; then
		MONGO_DB_VERSION=rhel70-4.2.6
	# RHEL 8
	elif [ $CODENAME = "Ootpa" ]; then
		MONGO_DB_VERSION=rhel80-4.2.6
	# Ubuntu 20.04, 19.10, or 18.04
	elif [ $CODENAME = "focal" -o $CODENAME = "eoan" -o $CODENAME = "bionic" ]; then
		MONGO_DB_VERSION=ubuntu1804-4.2.6
	fi 
    HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`
    DIST_PATH=`uname | tr [A-Z] [a-z]`
# Check darwin distributions 
elif [ `uname` == "Darwin" ]; then
    HOST_ARCH=macos-`uname -m`
    MONGO_DB_VERSION=4.2.6
    DIST_PATH=osx
fi

if [ -z $MONGO_DB_VERSION ]; then 
    echo "No configuration for installing mongodb support for your os distirbution has been defined"
    exit 1
fi

# Version should increment up if a script should perform an update to current installs. (int)
INSTALL_SCRIPT_VERSION=2
PROG_NAME='mongodb'
ARCHIVE_EXTENSION=tgz
fullName=mongodb-$HOST_ARCH-$MONGO_DB_VERSION
# Reset host arch for custom implementations in OSX
HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`

srcDir=$topDir/src
installDir=$topDir/$PROG_NAME
fullInstallDir=$installDir/$HOST_ARCH
INSTALL_SCRIPT_VERSION_PATH=$fullInstallDir/installScriptVersion

DOWNLOAD_URL=https://fastdl.mongodb.org/$DIST_PATH/$fullName.$ARCHIVE_EXTENSION

if [ -d $fullInstallDir ]; then
	if [ $INSTALL_SCRIPT_VERSION -gt `cat $INSTALL_SCRIPT_VERSION_PATH` ]; then 
		echo "$PROG_NAME needs to be updated"
	elif [ "x$1" = "x--force" ]; then 
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
		if [ ! "x$1" = "x--silent" ]; then 
			echo "Running the install script with the switch --force to override install"
		fi
		exit 1
	fi	
else 
	echo "$PROG_NAME needs to be installed"
fi 

if [ "x$1" = "x--silent" ]; then 
	exit 0
else
	echo "removing directory $fullInstallDir"
	rm -Rf $fullInstallDir
fi

if [ ! -d $srcDir ]; then
    mkdir $srcDir
fi

cd $srcDir 
curl -O $DOWNLOAD_URL

mkdir -p $installDir
cd $installDir

tar zvxf $srcDir/$fullName.$ARCHIVE_EXTENSION
# rename the directory 
mv $fullName $HOST_ARCH

echo "$PROG_NAME has been installed in $fullInstallDir"
echo $INSTALL_SCRIPT_VERSION > $INSTALL_SCRIPT_VERSION_PATH

cd $currentDir
