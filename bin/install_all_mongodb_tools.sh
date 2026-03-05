#!/bin/sh

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`
binDir=$topDir/bin

$binDir/install_mongodb.sh $1
$binDir/install_mongosh.sh $1
$binDir/install_mongodb_database_tools.sh $1
$binDir/setup_mongodb_paths.sh
