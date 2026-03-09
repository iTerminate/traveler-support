#!/bin/sh

cd `dirname $0`/.. && topDir=`pwd`

TIMESTAMP=`date +%Y%m%d_%H%M%S`
SNAPSHOT_DIR="$topDir/snapshots/$TIMESTAMP"

# Move existing directories into the snapshot
for dir in mongodb mongodb-server mongosh mongodb-database-tools nodejs; do
    if [ -d "$topDir/$dir" ]; then
        mkdir -p "$SNAPSHOT_DIR"
        mv "$topDir/$dir" "$SNAPSHOT_DIR/$dir"
    fi
done

if [ -d "$SNAPSHOT_DIR" ]; then
    echo ""
    echo "Previous support files have been saved to:"
    echo "  $SNAPSHOT_DIR"
    echo ""
    echo "To remove the snapshot manually, run:"
    echo "  rm -rf $SNAPSHOT_DIR"
    echo ""
else
    echo "Nothing to clean — no directories found."
fi
