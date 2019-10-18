#!/bin/bash

# change directories to a factor module
function cdfactor {
    code=$(printf "USING: io io.backend vocabs vocabs.loader ; "
           printf "\"%s\" <vocab> vocab-source-path normalize-path print" $1)
    fn=$(factor -e="$code")
    dn=$(dirname $fn)
    echo $dn
    if [ -z "$dn" ]; then
        echo "Warning: directory '$1' not found" 1>&2
    else
        cd $dn
    fi
}
