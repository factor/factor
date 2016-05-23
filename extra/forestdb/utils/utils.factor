! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations forestdb.ffi forestdb.lib
fry io.directories io.files.temp io.files.unique
io.files.unique.private io.pathnames kernel locals math.parser
math.ranges namespaces sequences splitting ;
IN: forestdb.utils

: fdb-test-config-seqtree-auto ( -- config )
    fdb_get_default_config
        FDB_COMPACTION_AUTO >>compaction_mode
        FDB_SEQTREE_USE >>seqtree_opt ;

: fdb-test-config-seqtree-manual ( -- config )
    fdb_get_default_config
        FDB_COMPACTION_MANUAL >>compaction_mode
        FDB_SEQTREE_USE >>seqtree_opt ;

! Manual naming scheme: foo.db
: do-forestdb-test-db-manual ( config quot -- )
    '[
        "forestdb-test-manual" ".db" [
            _
            "default" _ with-forestdb-path-config-kvs-name
        ] cleanup-unique-file
    ] with-temp-directory ; inline

! Auto naming scheme: foo.db.0 foo.db.meta
: do-forestdb-test-db-auto ( config quot -- )
    '[
        "forestdb-test-auto" { ".db.0" ".db.meta" } [
            first ".0" ?tail drop
            _ "default" _ with-forestdb-path-config-kvs-name
        ] cleanup-unique-files
    ] with-temp-directory ; inline

: with-forestdb-test-db ( config quot -- )
    over [
        do-forestdb-test-db-manual
    ] [
        do-forestdb-test-db-auto
    ] if ; inline

: with-forestdb-test-manual ( quot -- )
    [ fdb-test-config-seqtree-manual ] dip do-forestdb-test-db-manual ; inline

: with-forestdb-test-auto ( quot -- )
    [ fdb-test-config-seqtree-auto ] dip do-forestdb-test-db-auto ; inline

: make-kv-nth ( n -- key val )
    number>string [ "key" prepend ] [ "val" prepend ] bi ;

: make-kv-n ( n -- seq )
    [1,b] [ make-kv-nth ] { } map>assoc ;

: make-kv-range ( a b -- seq )
    [a,b] [ make-kv-nth ] { } map>assoc ;

: set-kv-n ( n -- )
    make-kv-n [ fdb-set-kv ] assoc-each ;

: del-kv-n ( n -- )
    make-kv-n keys [ fdb-del-kv ] each ;

: set-kv-nth ( n -- )
    make-kv-nth fdb-set-kv ;

: set-kv-range ( a b -- )
    make-kv-range [ fdb-set-kv ] assoc-each ;
