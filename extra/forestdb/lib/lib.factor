! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
classes.struct combinators destructors forestdb.ffi fry
generalizations io.encodings.string io.encodings.utf8
io.pathnames kernel libc namespaces sequences ;
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


TUPLE: fdb-doc < disposable doc ;
M: fdb-doc dispose*
    fdb_doc_free check-forestdb-error ;


: open-default-forestdb ( path -- handle )
    [ f void* <ref> ] dip
    absolute-path f
    [ fdb_open check-forestdb-error ] 3keep 2drop void* deref <fdb-handle> ;

: ret>string ( void** len -- string )
    [ void* deref ] [ size_t deref ] bi*
    [ memory>byte-array utf8 decode ] [ drop (free) ] 2bi ;

SYMBOL: current-forestdb

: get-handle ( -- handle )
    current-forestdb get handle>> ;

: fdb-set-kv ( key value -- )
    [ get-handle ] 2dip
    [ dup length ] bi@ fdb_set_kv check-forestdb-error ;

: fdb-set ( doc -- )
    [ get-handle ] dip fdb_set check-forestdb-error ;

: fdb-del ( doc -- )
    [ get-handle ] dip fdb_del check-forestdb-error ;

: fdb-get-kv ( key -- value/f )
    [ get-handle ] dip
    dup length f void* <ref> 0 size_t <ref>
    [ fdb_get_kv ] 2keep
    rot {
        { FDB_RESULT_SUCCESS [ ret>string ] }
        { FDB_RESULT_KEY_NOT_FOUND [ 2drop f ] }
        [ fdb-error ]
    } case ;

: fdb-del-kv ( key -- )
    [ get-handle ] dip dup length fdb_del_kv check-forestdb-error ;

: fdb-doc-create ( key meta body -- doc )
    [ f void* <ref> ] 3dip
    [ dup length ] tri@
    [ fdb_doc_create check-forestdb-error ] 7 nkeep 6 ndrop
    void* deref fdb_doc memory>struct ;

: fdb-doc-update ( doc meta body -- )
    [ void* <ref> ] 2dip
    [ dup length ] bi@
    fdb_doc_update check-forestdb-error ;

: fdb-doc-free ( doc -- )
    fdb_doc_free check-forestdb-error ;


: get-current-db-info ( -- info )
    get-handle
    fdb_info <struct> [ fdb_get_dbinfo check-forestdb-error ] keep ;

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
