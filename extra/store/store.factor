! Copyright (C) 2006, 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io io.files kernel namespaces serialize init ;
IN: store

TUPLE: store path data ;

C: <store> store

: save-store ( store -- )
    get-global dup store-data swap store-path
    <file-writer> [ serialize ] with-stream ;

: load-store ( path -- store )
    dup exists? [
        dup <file-reader> [ deserialize ] with-stream
    ] [
        H{ } clone
    ] if <store> ;

: define-store ( path id -- )
    over >r
    [ >r resource-path load-store r> set-global ] 2curry
    r> add-init-hook ;

: get-persistent ( key store -- value )
    get-global store-data at ;

: set-persistent ( value key store -- )
    [ get-global store-data set-at ] keep save-store ;

: init-persistent ( value key store -- )
    2dup get-persistent [ 3drop ] [ set-persistent ] if ;
