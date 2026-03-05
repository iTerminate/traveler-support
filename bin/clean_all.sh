#!/bin/sh

cd `dirname $0`/.. && topDir=`pwd`

rm -rf $topDir/mongodb
rm -rf $topDir/mongodb-server
rm -rf $topDir/mongosh
rm -rf $topDir/mongodb-database-tools
rm -rf $topDir/nodejs