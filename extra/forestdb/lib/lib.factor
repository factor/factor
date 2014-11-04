! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
combinators destructors forestdb.ffi fry io.encodings.string
io.encodings.utf8 io.pathnames kernel libc namespaces sequences ;
IN: forestdb.lib

ERROR: fdb-error error ;

: check-forestdb-error ( ret -- )
    dup FDB_RESULT_SUCCESS = [
        drop
    ] [
        fdb-error
    ] if ;

TUPLE: fdb-handle < disposable handle ;
: <fdb-handle> ( handle -- obj )
    fdb-handle new-disposable
        swap >>handle ; inline

M: fdb-handle dispose*
    handle>> fdb_close check-forestdb-error ;

: open-default-forestdb ( path -- handle )
    [ f void* <ref> ] dip
    absolute-path f
    [ fdb_open check-forestdb-error ] 3keep 2drop void* deref <fdb-handle> ;

SYMBOL: current-forestdb

: get-handle ( -- handle )
    current-forestdb get handle>> ;

: fdb-set ( key value -- )
    [ get-handle ] 2dip
    [ dup length ] bi@ fdb_set_kv check-forestdb-error ;

: ret>string ( void** len -- string )
    [ void* deref ] [ size_t deref ] bi*
    [ memory>byte-array utf8 decode ] [ drop (free) ] 2bi ;

: fdb-get ( key -- value/f )
    [ get-handle ] dip
    dup length f void* <ref> 0 size_t <ref>
    [ fdb_get_kv ] 2keep
    rot {
        { FDB_RESULT_SUCCESS [ ret>string ] }
        { FDB_RESULT_KEY_NOT_FOUND [ 2drop f ] }
        [ fdb-error ]
    } case ;

: commit-forestdb ( -- )
    get-handle FDB_COMMIT_NORMAL fdb_commit check-forestdb-error ;

: with-forestdb ( path quot -- )
    [ absolute-path open-default-forestdb ] dip
    dupd '[
        _ current-forestdb [
            _ &dispose drop
            @
            commit-forestdb
        ] with-variable
    ] with-destructors ; inline
