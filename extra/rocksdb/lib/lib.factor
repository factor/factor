! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
constructors destructors io.encodings.string io.encodings.utf8
kernel namespaces rocksdb.ffi sequences ;
IN: rocksdb.lib

! https://github.com/facebook/rocksdb/blob/c08c0ae73131457a2ac74507da58ff49870c1ee6/db/c_test.c

: rocksdb-ptr-error ( ptr/f error-ptrptr -- ptr/f )
    over
    [ drop ]
    [ void* deref alien>native-string throw ] if ;

TUPLE: rocksdb-handle < disposable ptr ;
CONSTRUCTOR: <rocksdb-handle> rocksdb-handle ( ptr -- handle ) ;
M: rocksdb-handle dispose
    ptr>> rocksdb_close ;

TUPLE: rocksdb-options < disposable ptr ;
CONSTRUCTOR: <rocksdb-options> rocksdb-options ( ptr -- options ) ;
M: rocksdb-options dispose
    ptr>> rocksdb_options_destroy ;

: set-create-if-missing ( options -- options )
    [ 1 rocksdb_options_set_create_if_missing ] keep ;

: create-rocksdb ( path -- ptr )
    [
        rocksdb_options_create [ <rocksdb-options> &dispose drop ] keep
        set-create-if-missing
    ] dip f void* <ref>
    [ rocksdb_open ] keep rocksdb-ptr-error ;

SYMBOL: rocksdb-handle-var

: with-rocksdb ( path quot -- )
    [
        [
            create-rocksdb [ <rocksdb-handle> &dispose drop ] keep
            dup rocksdb-handle-var
        ] dip
         with-variable
    ] with-destructors ; inline

! Writing
SYMBOL: rocksdb-write-options-var

TUPLE: rocksdb-write-options < disposable ptr ;
CONSTRUCTOR: <rocksdb-write-options> rocksdb-write-options ( ptr -- options ) ;
M: rocksdb-write-options dispose
    ptr>> rocksdb_writeoptions_destroy ;

: make-write-options-sync ( -- write-options )
    rocksdb_writeoptions_create [ 1 rocksdb_writeoptions_set_sync ] keep
    [ <rocksdb-write-options> &dispose drop ] keep ;

: make-write-options-async ( -- write-options )
    rocksdb_writeoptions_create [ 0 rocksdb_writeoptions_set_sync ] keep
    [ <rocksdb-write-options> &dispose drop ] keep ;

: rocksdb-put* ( db write-options key value -- error/f )
    [ utf8 encode dup length ] bi@
    f void* <ref>
    [ rocksdb_put ] keep
    dup [ void* deref alien>native-string ] when ;

! Reading

SYMBOL: rocksdb-read-options-var

TUPLE: rocksdb-read-options < disposable ptr ;
CONSTRUCTOR: <rocksdb-read-options> rocksdb-read-options ( ptr -- options ) ;
M: rocksdb-read-options dispose
    ptr>> rocksdb_readoptions_destroy ;


: make-read-options ( -- read-options )
    rocksdb_readoptions_create
    [ <rocksdb-read-options> &dispose drop ] keep ;

! : with-default-rocksdb-read-options ( quot -- )
!    [ make-read-options rocksdb-read-options-var ] dip with-variable ; inline

: rocksdb-get* ( db read-options key -- value/f error/f )
    utf8 encode dup length
    0 size_t <ref>
    f void* <ref>
    [ rocksdb_get ] 2keep
    dup [ void* deref alien>native-string ] when
    dup [
        [ 2drop f ] dip
    ] [
        [ size_t deref memory>byte-array ] dip
    ] if ;

! Deleting

: rocksdb-delete* ( db write-options key -- error/f )
    utf8 encode dup length
    f void* <ref>
    [ rocksdb_delete ] keep
    dup [ void* deref alien>native-string ] when ;
