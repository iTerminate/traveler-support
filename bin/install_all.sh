#!/bin/sh

# Passing a number as an argument specifies the number of jobs for the make program whenever used. 

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`
binDir=$topDir/bin

$binDir/install_nodejs.sh $1
$binDir/install_pm2.sh $1
$binDir/install_mongo-express.sh $1
$binDir/install_mongodb.sh $1
