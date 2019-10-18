! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io namespaces serialize kernel assocs ;
IN: store

TUPLE: store path data ;
: save-store ( store -- )
    [ store-data ] keep store-path <file-writer> [
        [
            dup
            [ drop [ get ] keep rot set-at ] assoc-each-with
        ] keep [ serialize ] with-serialized
    ] with-stream ;

: load-store ( path -- store )
    resource-path dup exists? [
        dup <file-reader> [
            [ deserialize ] with-serialized
        ] with-stream
    ] [
        H{ } clone
    ] if <store> ;

: store-variable ( default variable store -- )
    store-data 2dup at* [
        rot set-global 2drop
    ] [
        drop >r 2dup set-global r> set-at
    ] if ;

