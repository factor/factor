! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays classes.struct
combinators constructors continuations destructors forestdb.ffi
forestdb.paths fry generalizations io.encodings.string
io.encodings.utf8 io.pathnames kernel libc math multiline
namespaces sequences ;
QUALIFIED: sets
IN: forestdb.lib

/*
! Issues
! 2) build on macosx doesn't search /usr/local for libsnappy
! 3) build on macosx doesn't include -L/usr/local/lib when it finds snappy
!  - link_directories(/usr/local/lib) or some other fix
! 4) byseq iteration doesn't have bodies, weird.
! 5) Get byseq ignores seqnum and uses key instead if key is set

*/

ERROR: fdb-error error ;

: fdb-check-error ( ret -- )
    dup FDB_RESULT_SUCCESS = [ drop ] [ fdb-error ] if ;

TUPLE: fdb-handle < disposable handle ;
: <fdb-handle> ( handle -- obj )
    fdb-handle new-disposable
        swap >>handle ; inline

M: fdb-handle dispose*
    handle>> fdb_kvs_close fdb-check-error ;


TUPLE: fdb-file-handle < disposable handle ;
: <fdb-file-handle> ( handle -- obj )
    fdb-file-handle new-disposable
        swap >>handle ; inline

M: fdb-file-handle dispose*
    handle>> fdb_close fdb-check-error ;

TUPLE: fdb-handle-pair < disposable file-handle handle ;

: <fdb-handle-pair> ( file-handle handle -- obj )
    fdb-handle-pair new-disposable
        swap >>handle
        swap >>file-handle ; inline

M: fdb-handle-pair dispose*
    [
        [ handle>> ] [ file-handle>> ] bi 2array dispose-each
    ] with-destructors ;

TUPLE: fdb-doc < disposable doc ;

M: fdb-doc dispose*
    fdb_doc_free fdb-check-error ;

SYMBOL: fdb-current

: get-kvs-default-config ( -- kvs-config )
    S{ fdb_kvs_config
        { create_if_missing t }
        { custom_cmp f }
    } clone ;

: fdb-open-kvs ( fdb-file-handle kvs-config -- fdb-handle-pair )
    [
        [
            |dispose dup handle>> ! possibly clean up fdb_file_handle
            f void* <ref>
        ] dip
        [ fdb_kvs_open_default fdb-check-error ] 2keep drop
        void* deref <fdb-handle>
        <fdb-handle-pair>
    ] with-destructors ;

: fdb-open ( path config kvs-config -- fdb-handle-pair )
    [
        [ f void* <ref> ] 2dip
        [ absolute-path ensure-fdb-filename-directory ] dip
        [ fdb_open fdb-check-error ] 3keep
        2drop void* deref <fdb-file-handle>
    ] dip fdb-open-kvs ;

: fdb-open-default-config ( path -- fdb-handle-pair )
    fdb_get_default_config get-kvs-default-config fdb-open ;

: ret>string ( void** len -- string )
    [ void* deref ] [ size_t deref ] bi*
    [ memory>byte-array utf8 decode ] [ drop (free) ] 2bi ;

: get-file-handle ( -- handle )
    fdb-current get file-handle>> handle>> ;

: get-handle ( -- handle )
    fdb-current get handle>> handle>> ;

: fdb-set-kv ( key value -- )
    [ get-handle ] 2dip
    [ dup length ] bi@ fdb_set_kv fdb-check-error ;

: <key-doc> ( key -- doc )
    fdb_doc malloc-struct
        swap [ utf8 malloc-string >>key ] [ length >>keylen ] bi ;

: <seqnum-doc> ( seqnum -- doc )
    fdb_doc malloc-struct
        swap >>seqnum ;

! Fill in document by exemplar
: fdb-get ( doc -- doc )
    [ get-handle ] dip [ fdb_get fdb-check-error ] keep ;

: fdb-get-metaonly ( doc -- doc )
    [ get-handle ] dip [ fdb_get_metaonly fdb-check-error ] keep ;

: fdb-get-byseq ( doc -- doc )
    [ get-handle ] dip [ fdb_get_byseq fdb-check-error ] keep ;

: fdb-get-metaonly-byseq ( doc -- doc )
    [ get-handle ] dip [ fdb_get_metaonly_byseq fdb-check-error ] keep ;

: fdb-get-byoffset ( doc -- doc )
    [ get-handle ] dip [ fdb_get_byoffset fdb-check-error ] keep ;


! Set/delete documents
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

: clear-doc-key ( doc -- doc )
    [ dup [ (free) f ] when ] change-key
    0 >>keylen ;

: with-doc ( doc quot: ( doc -- ) -- )
    over '[ _ _ [ _ fdb-doc-free rethrow ] recover ] call ; inline

: with-create-doc ( key meta body quot: ( doc -- ) -- )
    [ fdb-doc-create ] dip with-doc ; inline

: fdb-get-info ( -- fdb_info )
    get-file-handle
    fdb_info <struct> [ fdb_get_dbinfo fdb-check-error ] keep ;

: fdb-get-seqnum ( -- fdb_info )
    get-handle
    1020 fdb_seqnum_t <ref> [ fdb_get_seqnum fdb-check-error ] keep
    fdb_seqnum_t deref ;

: fdb-get-kvs-info ( -- fdb_kvs_info )
    get-handle
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

: fdb-swap-current-db ( new-path -- )
    [
        fdb-current get dispose
        fdb-open-default-config fdb-current set
    ] with-destructors ;

: fdb-compact-and-swap-db ( path -- )
    next-vnode-version-name
    [ fdb-compact fdb-commit-wal-flush ]
    [ fdb-swap-current-db ] bi ;


! Call from within with-foresdb
: fdb-open-snapshot ( seqnum -- handle-pair )
    [
        get-handle
        f void* <ref>
    ] dip [
        fdb_snapshot_open fdb-check-error
    ] 2keep drop void* deref <fdb-handle>
    get-kvs-default-config
    fdb-open-kvs ;

! fdb_rollback returns a new handle, so we
! have to replace our current handle with that one
! XXX: can't call dispose on old handle, library handles that
: fdb-rollback ( seqnum -- )
    [ get-handle void* <ref> ] dip
    [ fdb_rollback fdb-check-error ] 2keep drop
    void* deref <fdb-handle> fdb-current set ;


TUPLE: fdb-iterator < disposable handle ;

: <fdb-iterator> ( handle -- obj )
    fdb-iterator new-disposable
        swap >>handle ; inline

M: fdb-iterator dispose*
    handle>> fdb_iterator_close fdb-check-error ;


: fdb-iterator-init ( start-key end-key fdb_iterator_opt_t -- iterator )
    [ get-handle f void* <ref> ] 3dip
    [ [ dup length ] bi@ ] dip
    [ fdb_iterator_init fdb-check-error ] 7 nkeep 5 ndrop nip
    void* deref <fdb-iterator> ;

: fdb-iterator-byseq-init ( start-seq end-seq fdb_iterator_opt_t -- iterator )
    [ get-handle f void* <ref> ] 3dip
    [ fdb_iterator_sequence_init fdb-check-error ] 5 nkeep 3 ndrop nip
    void* deref <fdb-iterator> ;

: fdb-iterator-init-none ( start-key end-key -- iterator )
    FDB_ITR_NONE fdb-iterator-init ;

: fdb-iterator-meta-only ( start-key end-key -- iterator )
    FDB_ITR_METAONLY fdb-iterator-init ;

: fdb-iterator-no-deletes ( start-key end-key -- iterator )
    FDB_ITR_NO_DELETES fdb-iterator-init ;

: check-iterate-result ( doc fdb_status -- doc/f )
    {
        { FDB_RESULT_SUCCESS [ void* deref fdb_doc memory>struct ] }
        { FDB_RESULT_ITERATOR_FAIL [ drop f ] }
        [ throw ]
    } case ;

: fdb-iterate ( iterator word -- doc )
    '[
        fdb_doc malloc-struct fdb_doc <ref>
        [ _ execute ] keep swap check-iterate-result
    ] call ; inline

! fdb_doc key, meta, body only valid inside with-forestdb
! so make a helper word to preserve them outside
TUPLE: doc seqnum keylen key metalen meta bodylen body deleted? offset size-ondisk ;

CONSTRUCTOR: <doc> doc ( seqnum keylen key metalen meta bodylen body deleted? offset size-ondisk -- obj ) ;

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
    } cleave <doc> ;

: fdb-iterator-prev ( iterator -- doc/f ) \ fdb_iterator_prev fdb-iterate ;
: fdb-iterator-next ( iterator -- doc/f ) \ fdb_iterator_next fdb-iterate ;
: fdb-iterator-next-meta-only ( iterator -- doc/f ) \ fdb_iterator_next_metaonly fdb-iterate ;
: fdb-iterator-seek ( iterator key -- )
    dup length fdb_iterator_seek fdb-check-error ;

: with-fdb-iterator ( start-key end-key fdb_iterator_opt_t iterator-init iterator-next quot: ( obj -- ) -- )
    [ execute ] 2dip
    '[
        _ &dispose handle>> [
            _ execute [ _ with-doc t ] [ f ] if*
        ] curry loop
    ] with-destructors ; inline

<PRIVATE

: collector-for-when ( quot exemplar -- quot' vec )
    [ length ] keep new-resizable [ [ over [ push ] [ 2drop ] if ] curry compose ] keep ; inline

: collector-when ( quot -- quot' vec )
    V{ } collector-for-when ; inline

PRIVATE>

: with-fdb-map ( start-key end-key fdb_iterator_opt_t iterator-init iterator-next quot: ( obj -- ) -- )
    [ execute ] 2dip
    '[
        _ &dispose handle>> [
            _ execute [ _ with-doc t ] [ f f ] if* swap
        ] curry collector-when [ loop ] dip
    ] with-destructors ; inline

: with-fdb-normal-iterator ( start-key end-key quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-init \ fdb-iterator-next ] dip
    with-fdb-iterator ; inline

: with-fdb-normal-meta-iterator ( start-key end-key quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-init \ fdb-iterator-next-meta-only ] dip
    with-fdb-iterator ; inline

: with-fdb-byseq-each ( start-seq end-seq quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-byseq-init \ fdb-iterator-next-meta-only ] dip
    with-fdb-iterator ; inline

: with-fdb-byseq-map ( start-seq end-seq quot -- )
    [ FDB_ITR_NONE \ fdb-iterator-byseq-init \ fdb-iterator-next-meta-only ] dip
    with-fdb-map ; inline

! Do not try to commit here, as it will fail with FDB_RESULT_RONLY_VIOLATION
! fdb-current is weird, it gets replaced if you call fdb-rollback
! Therefore, only clean up fdb-current once, and clean it up at the end
: with-forestdb-handle ( handle-pair quot fdb_commit_opt_t/f -- )
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

! XXX: When you don't commit-wal at the end of with-forestdb, it won't
! persist to disk for next time you open the db.
: with-forestdb-handle-commit-normal ( handle-pair quot commit -- )
    FDB_COMMIT_NORMAL with-forestdb-handle ; inline

: with-forestdb-handle-commit-wal ( handle-pair quot commit -- )
    FDB_COMMIT_MANUAL_WAL_FLUSH with-forestdb-handle ; inline

: with-forestdb-snapshot ( handle-pair quot commit -- )
    f with-forestdb-handle ; inline

: with-forestdb-path ( path quot -- )
    [ absolute-path fdb-open-default-config ] dip with-forestdb-handle-commit-wal ; inline
    ! [ absolute-path fdb-open-default-config ] dip with-forestdb-handle-commit-normal ; inline
