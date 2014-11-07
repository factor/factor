! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.syntax classes.struct combinators continuations
destructors forestdb.ffi fry generalizations io.encodings.string
io.encodings.utf8 io.pathnames kernel libc multiline namespaces
sequences ;
IN: forestdb.lib

ERROR: fdb-error error ;

: fdb-check-error ( ret -- )
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
    handle>> fdb_close fdb-check-error ;


TUPLE: fdb-doc < disposable doc ;
M: fdb-doc dispose*
    fdb_doc_free fdb-check-error ;


: fdb-open ( path -- handle )
    [ f void* <ref> ] dip
    absolute-path f
    [ fdb_open fdb-check-error ] 3keep
    2drop void* deref <fdb-handle> ;

: ret>string ( void** len -- string )
    [ void* deref ] [ size_t deref ] bi*
    [ memory>byte-array utf8 decode ] [ drop (free) ] 2bi ;

SYMBOL: fdb-current

: get-handle ( -- handle )
    fdb-current get handle>> ;

: fdb-set-kv ( key value -- )
    [ get-handle ] 2dip
    [ dup length ] bi@ fdb_set_kv fdb-check-error ;

: fdb-set ( doc -- )
    [ get-handle ] dip fdb_set fdb-check-error ;

: fdb-del ( doc -- )
    [ get-handle ] dip fdb_del fdb-check-error ;

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
    [ get-handle ] dip dup length fdb_del_kv fdb-check-error ;

: fdb-doc-create ( key meta body -- doc )
    [ f void* <ref> ] 3dip
    [ dup length ] tri@
    [ fdb_doc_create fdb-check-error ] 7 nkeep 6 ndrop
    void* deref fdb_doc memory>struct ;

: fdb-doc-update ( doc meta body -- )
    [ void* <ref> ] 2dip
    [ dup length ] bi@
    fdb_doc_update fdb-check-error ;

: fdb-doc-free ( doc -- )
    fdb_doc_free fdb-check-error ;

: fdb-info ( -- info )
    get-handle
    fdb_info <struct> [ fdb_get_dbinfo fdb-check-error ] keep ;

: fdb-commit ( fdb_commit_opt_t -- )
    [ get-handle ] dip fdb_commit fdb-check-error ;

: fdb-maybe-commit ( fdb_commit_opt_t/f -- )
    [ fdb-commit ] when* ;

: fdb-commit-normal ( -- ) FDB_COMMIT_NORMAL fdb-commit ;

: fdb-commit-wal-flush ( -- ) FDB_COMMIT_MANUAL_WAL_FLUSH fdb-commit ;

FUNCTION: fdb_status fdb_rollback ( fdb_handle** handle_ptr, fdb_seqnum_t rollback_seqnum ) ;

! Call from within with-foresdb
: fdb-open-snapshot ( seqnum -- handle )
    [
        get-handle
        f void* <ref>
    ] dip [
        fdb_snapshot_open fdb-check-error
    ] 2keep drop void* deref <fdb-handle> ;

! fdb_rollback returns a new handle, so we
! have to replace our current handle with that one
! XXX: can't call dispose on old handle, library handles that
: fdb-rollback ( seqnum -- )
    [ get-handle void* <ref> ] dip
    [ fdb_rollback fdb-check-error ] 2keep drop
    void* deref <fdb-handle> fdb-current set ;

/*
FUNCTION: fdb_status fdb_iterator_init ( fdb_handle* handle, fdb_iterator** iterator, c-string start_key, size_t start_keylen, c-string end_key, size_t end_keylen, fdb_iterator_opt_t opt ) ;
FUNCTION: fdb_status fdb_iterator_sequence_init ( fdb_handle* handle, fdb_iterator** iterator, fdb_seqnum_t start_seq, fdb_seqnum_t end_seq, fdb_iterator_opt_t opt ) ;
FUNCTION: fdb_status fdb_iterator_prev ( fdb_iterator* iterator, fdb_doc** doc ) ;
FUNCTION: fdb_status fdb_iterator_next ( fdb_iterator* iterator, fdb_doc** doc ) ;
FUNCTION: fdb_status fdb_iterator_next_metaonly ( fdb_iterator* iterator, fdb_doc** doc ) ;
FUNCTION: fdb_status fdb_iterator_seek ( fdb_iterator* iterator, c-string seek_key, size_t seek_keylen ) ;
FUNCTION: fdb_status fdb_iterator_close ( fdb_iterator* iterator ) ;
*/

! Do not try to commit here, as it will fail with FDB_RESULT_RONLY_VIOLATION
! fdb-current is weird, it gets replaced if you call fdb-rollback
! Therefore, only clean up fdb-current once, and clean it up at the end
: with-forestdb-handle ( handle quot fdb_commit_opt_t/f -- )
    '[
        _ fdb-current [
            [
                @
                _ fdb-maybe-commit
                fdb-current get &dispose drop
            ] [
                fdb-current get &dispose drop
                rethrow
            ] recover
        ] with-variable
    ] with-destructors ; inline

! Commit normal at the end
: with-forestdb-handle-commit-normal ( handle quot commit -- )
    FDB_COMMIT_NORMAL with-forestdb-handle ; inline

: with-forestdb-handle-commit-wal ( handle quot commit -- )
    FDB_COMMIT_MANUAL_WAL_FLUSH with-forestdb-handle ; inline

: with-forestdb-snapshot ( handle quot commit -- )
    f with-forestdb-handle ; inline

: with-forestdb-path ( path quot -- )
    [ absolute-path fdb-open ] dip with-forestdb-handle-commit-normal ; inline
