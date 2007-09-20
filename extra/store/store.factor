! Copyright (C) 2006, 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io io.files kernel namespaces serialize ;
IN: store

TUPLE: store path data ;

C: <store> store

: save-store ( store -- )
    [ store-data ] keep store-path <file-writer> [
        [
            dup
            [ drop [ get ] keep rot set-at ] curry* assoc-each
        ] keep serialize
    ] with-stream ;

: load-store ( path -- store )
    resource-path dup exists? [
        dup <file-reader> [
            deserialize
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

