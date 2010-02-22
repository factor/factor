#!/bin/bash 

# change directories to a factor module
function cdfactor { 
    code=$(printf "USING: io io.pathnames vocabs vocabs.loader ; "
           printf "\"%s\" <vocab> vocab-source-path absolute-path print" $1)
    echo $code > $HOME/.cdfactor
    fn=$(factor $HOME/.cdfactor)
    dn=$(dirname $fn)
    echo $dn
    if [ -z "$dn" ]; then
        echo "Warning: directory '$1' not found" 1>&2
    else
        cd $dn
    fi
}


