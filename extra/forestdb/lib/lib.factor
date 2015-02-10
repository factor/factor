! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
classes.struct combinators constructors continuations
destructors forestdb.ffi forestdb.paths fry generalizations
io.encodings.string io.encodings.utf8 io.pathnames kernel libc
math multiline namespaces sequences ;
QUALIFIED: sets
IN: forestdb.lib

/*
! Issues
! Get byseq ignores seqnum and uses key instead if key is set
*/

ERROR: fdb-error error ;

: fdb-check-error ( ret -- )
    dup FDB_RESULT_SUCCESS = [ drop ] [ fdb-error ] if ;


TUPLE: fdb-kvs-handle < disposable handle ;
: <fdb-kvs-handle> ( handle -- obj )
    fdb-kvs-handle new-disposable
        swap >>handle ; inline

M: fdb-kvs-handle dispose*
    handle>> fdb_kvs_close fdb-check-error ;


TUPLE: fdb-file-handle < disposable handle ;
: <fdb-file-handle> ( handle -- obj )
    fdb-file-handle new-disposable
        swap >>handle ; inline

M: fdb-file-handle dispose*
    handle>> fdb_close fdb-check-error ;


SYMBOL: current-fdb-file-handle
SYMBOL: current-fdb-kvs-handle

: get-file-handle ( -- handle )
    current-fdb-file-handle get handle>> ;

: get-kvs-handle ( -- handle )
    current-fdb-kvs-handle get handle>> ;

: fdb-set-kv ( key value -- )
    [ get-kvs-handle ] 2dip
    [ utf8 encode dup length ] bi@ fdb_set_kv fdb-check-error ;

: <key-doc> ( key -- doc )
    fdb_doc malloc-struct
        swap [ utf8 malloc-string >>key ] [ length >>keylen ] bi ;

: <seqnum-doc> ( seqnum -- doc )
    fdb_doc malloc-struct
        swap >>seqnum ;

! Fill in document by exemplar
: fdb-get ( doc -- doc )
    [ get-kvs-handle ] dip [ fdb_get fdb-check-error ] keep ;

: fdb-get-metaonly ( doc -- doc )
    [ get-kvs-handle ] dip [ fdb_get_metaonly fdb-check-error ] keep ;

: fdb-get-byseq ( doc -- doc )
    [ get-kvs-handle ] dip [ fdb_get_byseq fdb-check-error ] keep ;

: fdb-get-metaonly-byseq ( doc -- doc )
    [ get-kvs-handle ] dip [ fdb_get_metaonly_byseq fdb-check-error ] keep ;

: fdb-get-byoffset ( doc -- doc )
    [ get-kvs-handle ] dip [ fdb_get_byoffset fdb-check-error ] keep ;


! Set/delete documents
: fdb-set ( doc -- )
    [ get-kvs-handle ] dip fdb_set fdb-check-error ;

: fdb-del ( doc -- )
    [ get-kvs-handle ] dip fdb_del fdb-check-error ;

: ret>string ( void** len -- string )
    [ void* deref ] [ size_t deref ] bi*
    memory>byte-array utf8 decode ;

: fdb-get-kv ( key -- value/f )
    [ get-kvs-handle ] dip
    utf8 encode dup length f void* <ref> 0 size_t <ref>
    [ fdb_get_kv ] 2keep
    rot {
        { FDB_RESULT_SUCCESS [ ret>string ] }
        { FDB_RESULT_KEY_NOT_FOUND [ 2drop f ] }
        [ fdb-error ]
    } case ;

: fdb-del-kv ( key -- )
    [ get-kvs-handle ] dip
    utf8 encode dup length fdb_del_kv fdb-check-error ;

: fdb-doc-create ( key meta body -- doc )
    [ f void* <ref> ] 3dip
    [ utf8 encode dup length ] tri@
    [ fdb_doc_create fdb-check-error ] 7 nkeep 6 ndrop
    void* deref fdb_doc memory>struct ;

: fdb-doc-update ( doc meta body -- )
    [ void* <ref> ] 2dip
    [ utf8 encode dup length ] bi@
    fdb_doc_update fdb-check-error ;

: fdb-doc-free ( doc -- )
    fdb_doc_free fdb-check-error ;

: clear-doc-key ( doc -- doc )
    [ dup [ (free) f ] when ] change-key
    0 >>keylen ;

: with-doc ( doc quot: ( doc -- ) -- )
    over '[ _ _ [ _ fdb-doc-free rethrow ] recover ] call ; inline

: with-create-doc ( key meta body quot: ( doc -- ) -- )
    [ fdb-doc-create ] dip with-doc ; inline

: fdb-get-info ( -- fdb_file_info )
    get-file-handle
    fdb_file_info <struct> [ fdb_get_file_info fdb-check-error ] keep ;

: fdb-get-kvs-info ( -- fdb_kvs_info )
    get-kvs-handle
    fdb_kvs_info <struct> [ fdb_get_kvs_info fdb-check-error ] keep ;

: fdb-commit ( fdb_commit_opt_t -- )
    [ get-file-handle ] dip fdb_commit fdb-check-error ;

: fdb-maybe-commit ( fdb_commit_opt_t/f -- )
    [ fdb-commit ] when* ;

: fdb-commit-normal ( -- ) FDB_COMMIT_NORMAL fdb-commit ;

: fdb-commit-wal-flush ( -- ) FDB_COMMIT_MANUAL_WAL_FLUSH fdb-commit ;

: fdb-compact ( new-path -- )
    [ get-file-handle ] dip absolute-path
    fdb_compact fdb-check-error ;

: fdb-compact-commit ( new-path -- )
    fdb-compact fdb-commit-wal-flush ;


! Call from within with-foresdb
: fdb-open-snapshot ( seqnum -- handle )
    [
        get-kvs-handle
        f void* <ref>
    ] dip [
        fdb_snapshot_open fdb-check-error
    ] 2keep drop void* deref <fdb-kvs-handle> ;

! fdb_rollback returns a new handle, so we
! have to replace our current handle with that one
! XXX: can't call dispose on old handle, library handles that
: fdb-rollback ( seqnum -- )
    [ get-kvs-handle void* <ref> ] dip
    [ fdb_rollback fdb-check-error ] 2keep drop
    void* deref <fdb-kvs-handle> current-fdb-kvs-handle set ;


TUPLE: fdb-iterator < disposable handle ;

: <fdb-iterator> ( handle -- obj )
    fdb-iterator new-disposable
        swap >>handle ; inline

M: fdb-iterator dispose*
    handle>> fdb_iterator_close fdb-check-error ;

: fdb-iterator-init ( start-key end-key fdb_iterator_opt_t -- iterator )
    [ get-kvs-handle f void* <ref> ] 3dip
    [ [ utf8 encode dup length ] bi@ ] dip
    [ fdb_iterator_init fdb-check-error ] 7 nkeep 5 ndrop nip
    void* deref <fdb-iterator> ;

: fdb-iterator-byseq-init ( start-seq end-seq fdb_iterator_opt_t -- iterator )
    [ get-kvs-handle f void* <ref> ] 3dip
    [ fdb_iterator_sequence_init fdb-check-error ] 5 nkeep 3 ndrop nip
    void* deref <fdb-iterator> ;

: fdb-iterator-init-none ( start-key end-key -- iterator )
    FDB_ITR_NONE fdb-iterator-init ;

: fdb-iterator-no-deletes ( start-key end-key -- iterator )
    FDB_ITR_NO_DELETES fdb-iterator-init ;

: check-iterate-result ( fdb_status -- ? )
    {
        { FDB_RESULT_SUCCESS [ t ] }
        { FDB_RESULT_ITERATOR_FAIL [ f ] }
        [ throw ]
    } case ;

! fdb_doc key, meta, body only valid inside with-forestdb
! so make a helper word to preserve them outside
TUPLE: fdb-doc seqnum keylen key metalen meta bodylen body deleted? offset size-ondisk ;

CONSTRUCTOR: <fdb-doc> fdb-doc ( seqnum keylen key metalen meta bodylen body deleted? offset size-ondisk -- obj ) ;

TUPLE: fdb-info filename new-filename doc-count space-used file-size ;
CONSTRUCTOR: <info> fdb-info ( filename new-filename doc-count space-used file-size -- obj ) ;

/*
! Example fdb_doc and converted doc
S{ fdb_doc
    { keylen 4 } { metalen 0 } { bodylen 4 } { size_ondisk 0 }
    { key ALIEN: 1002f2f10 } { seqnum 5 } { offset 4256 }
    { meta ALIEN: 1002dc790 } { body f } { deleted f }
}
T{ doc
    { seqnum 5 }
    { keylen 4 } { key "key5" }
    { metalen 0 } { bodylen 4 }
    { offset 4256 } { size-ondisk 0 }
}
*/

: alien/length>string ( alien n -- string/f )
    [ drop f ] [
        over [
            memory>byte-array utf8 decode
        ] [
            2drop f
        ] if
    ] if-zero ;

: fdb_doc>doc ( fdb_doc -- doc )
    {
        [ seqnum>> ]
        [ keylen>> ]
        [ [ key>> ] [ keylen>> ] bi alien/length>string ]
        [ metalen>> ]
        [ [ meta>> ] [ metalen>> ] bi alien/length>string ]
        [ bodylen>> ]
        [ [ body>> ] [ bodylen>> ] bi alien/length>string ]
        [ deleted>> >boolean ]
        [ offset>> ]
        [ size_ondisk>> ]
    } cleave <fdb-doc> ;

: fdb_file_info>info ( fdb_doc -- doc )
    {
        [ filename>> alien>native-string ]
        [ new_filename>> alien>native-string ]
        [ doc_count>> ]
        [ space_used>> ]
        [ file_size>> ]
    } cleave <info> ;

: fdb-iterator-get ( iterator -- doc/f )
    f void* <ref>
    [ fdb_iterator_get check-iterate-result ] keep swap
    [ void* deref fdb_doc memory>struct ]
    [ drop f ] if ;

: fdb-iterator-seek ( iterator key seek-opt -- )
    [ dup length ] dip fdb_iterator_seek fdb-check-error ;

: fdb-iterator-seek-lower ( iterator key -- )
    FDB_ITR_SEEK_LOWER fdb-iterator-seek ;

: fdb-iterator-seek-higher ( iterator key -- )
    FDB_ITR_SEEK_HIGHER fdb-iterator-seek ;

: with-fdb-iterator ( start-key end-key fdb_iterator_opt_t iterator-init iterator-advance quot: ( obj -- ) -- )
    [ execute ] 2dip
    swap
    '[
        _ &dispose handle>> [
            [ fdb-iterator-get ] keep swap
            [ _ with-doc _ execute check-iterate-result ]
            [ drop f ] if*
        ] curry loop
    ] with-destructors ; inline

<PRIVATE

: collector-for-when ( quot exemplar -- quot' vec )
    [ length ] keep new-resizable [ [ over [ push ] [ 2drop ] if ] curry compose ] keep ; inline

: collector-when ( quot -- quot' vec )
    V{ } collector-for-when ; inline

PRIVATE>


: get-kvs-default-config ( -- kvs-config )
    S{ fdb_kvs_config
        { create_if_missing t }
        { custom_cmp f }
    } clone ;

: fdb-open ( path config -- file-handle )
    [ f void* <ref> ] 2dip
    [ absolute-path ensure-fdb-filename-directory ] dip
    [ fdb_open fdb-check-error ] 3keep
    2drop void* deref <fdb-file-handle> ;

: fdb-open-default-config ( path -- file-handle )
    fdb_get_default_config fdb-open ;

: fdb-kvs-open-config ( name config -- kvs-handle )
    [
        current-fdb-file-handle get handle>>
        f void* <ref>
    ] 2dip
    [ fdb_kvs_open fdb-check-error ] 3keep 2drop
    void* deref <fdb-kvs-handle> ;

: fdb-kvs-open ( name -- kvs-handle )
    get-kvs-default-config fdb-kvs-open-config ;

: with-fdb-map ( start-key end-key fdb_iterator_opt_t iterator-init iterator-next quot: ( obj -- ) -- )
    [ execute ] 2dip
    swap
    '[
        _ &dispose handle>> [
            [ fdb-iterator-get ] keep swap
            [ _ with-doc swap _ execute check-iterate-result ]
            [ drop f ] if* swap
        ] curry collector-when [ loop ] dip
    ] with-destructors ; inline

: with-fdb-normal-iterator ( start-key end-key quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-init \ fdb_iterator_next ] dip
    with-fdb-iterator ; inline

: with-fdb-byseq-each ( start-seq end-seq quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-byseq-init \ fdb_iterator_next ] dip
    with-fdb-iterator ; inline

: with-fdb-byseq-map ( start-seq end-seq quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-byseq-init \ fdb_iterator_next ] dip
    with-fdb-map ; inline


: with-kvs ( name quot -- )
    [
        [ fdb-kvs-open &dispose current-fdb-kvs-handle ] dip with-variable
    ] with-destructors ; inline


: with-default-kvs ( quot -- )
    [ "default" ] dip with-kvs ; inline

: with-forestdb ( path quot -- )
    [
        [ fdb-open-default-config &dispose current-fdb-file-handle ] dip with-variable
    ] with-destructors ; inline

: with-forestdb-kvs ( path name quot -- )
    '[
        _ _ with-kvs
    ] with-forestdb ; inline

/*
! Do not try to commit here, as it will fail with FDB_RESULT_RONLY_VIOLATION
! fdb-current is weird, it gets replaced if you call fdb-rollback
! Therefore, only clean up fdb-current once, and clean it up at the end
: with-forestdb-handles ( file-handle handle quot fdb_commit_opt_t/f -- )
    '[
        _ current-fdb-file-handle [
            _ current-fdb-kvs-handle [
                [
                    @
                    _ fdb-maybe-commit
                    current-fdb-file-handle get &dispose drop
                    current-fdb-kvs-handle get &dispose drop
                ] [
                    [
                        current-fdb-file-handle get &dispose drop
                        current-fdb-kvs-handle get &dispose drop
                    ] with-destructors
                    rethrow
                ] recover
            ] with-variable
        ] with-variable
    ] with-destructors ; inline

! XXX: When you don't commit-wal at the end of with-forestdb, it won't
! persist to disk for next time you open the db.
: with-forestdb-handles-commit-normal ( file-handle handle quot commit -- )
    FDB_COMMIT_NORMAL with-forestdb-handles ; inline

: with-forestdb-handles-commit-wal ( file-handle handle quot commit -- )
    FDB_COMMIT_MANUAL_WAL_FLUSH with-forestdb-handles ; inline

: with-forestdb-snapshot ( n quot -- )
    [ fdb-open-snapshot ] dip '[
        _ current-fdb-kvs-handle [
            [
                @
                current-fdb-kvs-handle get &dispose drop
            ] [
                current-fdb-kvs-handle get [ &dispose drop ] when*
                rethrow
            ] recover
        ] with-variable
    ] with-destructors ; inline

: with-forestdb-path ( path quot -- )
    [ absolute-path fdb-open-default-config ] dip with-forestdb-handles-commit-wal ; inline
    ! [ absolute-path fdb-open-default-config ] dip with-forestdb-handle-commit-normal ; inline
*/