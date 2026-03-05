#!/bin/bash

# Check linux distributions
if [ `uname` = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            rhel|centos|rocky|almalinux)
                VERSION_MAJOR=${VERSION_ID%%.*}
                case "$VERSION_MAJOR" in
                    9) MONGO_DB_VERSION=rhel93-8.0.19 ;;
                    8) MONGO_DB_VERSION=rhel8-8.0.19 ;;
                esac
                ;;
            ubuntu)
                case "$VERSION_ID" in
                    "24.04") MONGO_DB_VERSION=ubuntu2404-8.0.19 ;;
                    "22.04") MONGO_DB_VERSION=ubuntu2204-8.0.19 ;;
                    "20.04") MONGO_DB_VERSION=ubuntu2004-8.0.19 ;;
                esac
                ;;
        esac
    fi
    HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`
    DIST_PATH=`uname | tr [A-Z] [a-z]`
# Check darwin distributions
elif [ `uname` == "Darwin" ]; then
    HOST_ARCH=macos-`uname -m`
    MONGO_DB_VERSION=8.0.19
    DIST_PATH=osx
fi

if [ -z $MONGO_DB_VERSION ]; then 
    echo "No configuration for installing mongodb support for your os distirbution has been defined"
    exit 1
fi

# Version should increment up if a script should perform an update to current installs. (int)
INSTALL_SCRIPT_VERSION=3
PROG_NAME='mongodb-server'
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
mv mongodb-$HOST_ARCH-* $HOST_ARCH

echo "$PROG_NAME has been installed in $fullInstallDir"
echo $INSTALL_SCRIPT_VERSION > $INSTALL_SCRIPT_VERSION_PATH

cd $currentDir
