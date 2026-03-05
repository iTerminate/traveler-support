#!/bin/bash

DB_TOOLS_VERSION=100.14.1

if [ `uname` = "Linux" ]; then
    DB_TOOLS_ARCH=`uname -m`
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            rhel|centos|rocky|almalinux)
                VERSION_MAJOR=${VERSION_ID%%.*}
                case "$VERSION_MAJOR" in
                    9) DB_TOOLS_PLATFORM=rhel93 ;;
                    8) DB_TOOLS_PLATFORM=rhel88 ;;
                esac
                ;;
            ubuntu)
                case "$VERSION_ID" in
                    "24.04") DB_TOOLS_PLATFORM=ubuntu2404 ;;
                    "22.04") DB_TOOLS_PLATFORM=ubuntu2204 ;;
                    "20.04") DB_TOOLS_PLATFORM=ubuntu2004 ;;
                esac
                ;;
        esac
    fi
elif [ `uname` = "Darwin" ]; then
    DB_TOOLS_ARCH=`uname -m`
    DB_TOOLS_PLATFORM=macos
fi

if [ -z $DB_TOOLS_PLATFORM ]; then
    echo "No configuration for installing mongodb-database-tools support for your os distribution has been defined"
    exit 1
fi

HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`

# Version should increment up if a script should perform an update to current installs. (int)
INSTALL_SCRIPT_VERSION=1
PROG_NAME='mongodb-database-tools'
ARCHIVE_EXTENSION=tgz
fullName=$PROG_NAME-$DB_TOOLS_PLATFORM-$DB_TOOLS_ARCH-$DB_TOOLS_VERSION

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`

srcDir=$topDir/src
installDir=$topDir/$PROG_NAME
fullInstallDir=$installDir/$HOST_ARCH
INSTALL_SCRIPT_VERSION_PATH=$fullInstallDir/installScriptVersion

DOWNLOAD_URL=https://fastdl.mongodb.org/tools/db/$fullName.$ARCHIVE_EXTENSION

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
mv mongodb-database-tools-* $HOST_ARCH

echo "$PROG_NAME has been installed in $fullInstallDir"
echo $INSTALL_SCRIPT_VERSION > $INSTALL_SCRIPT_VERSION_PATH

cd $currentDir
