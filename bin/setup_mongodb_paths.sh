#!/bin/sh

currentDir=`pwd`
cd `dirname $0`/.. && topDir=`pwd`

HOST_ARCH=`uname | tr [A-Z] [a-z]`-`uname -m`

serverBin=$topDir/mongodb-server/$HOST_ARCH/bin
mongoshBin=$topDir/mongosh/$HOST_ARCH/bin
toolsBin=$topDir/mongodb-database-tools/$HOST_ARCH/bin

# Verify all three packages are installed
missing=0
for dir in "$serverBin" "$mongoshBin" "$toolsBin"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Required bin directory not found: $dir" >&2
        missing=1
    fi
done
if [ $missing -ne 0 ]; then
    exit 1
fi

unifiedBin=$topDir/mongodb/$HOST_ARCH/bin
mkdir -p "$unifiedBin"

linked=0
for srcDir in "$serverBin" "$mongoshBin" "$toolsBin"; do
    for srcFile in "$srcDir"/*; do
        [ -e "$srcFile" ] || continue
        name=`basename "$srcFile"`
        ln -sf "$srcFile" "$unifiedBin/$name"
        echo "  linked: $name -> $srcFile"
        linked=$((linked + 1))
    done
done

echo "setup_mongodb_paths: $linked binaries linked in $unifiedBin"

cd $currentDir
