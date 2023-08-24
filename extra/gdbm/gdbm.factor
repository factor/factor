! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors
alien.enums alien.syntax classes.struct combinators continuations
destructors fry gdbm.ffi io.backend kernel libc locals math namespaces
sequences serialize strings ;
IN: gdbm

ENUM: gdbm-role reader writer wrcreat newdb ;

TUPLE: gdbm
    { name string }
    { block-size integer }
    { role initial: wrcreat }
    { sync boolean }
    { nolock boolean }
    { mode integer initial: 0o644 } ;

: <gdbm> ( -- gdbm ) gdbm new ;

ENUM: gdbm-error
    gdbm-no-error
    gdbm-malloc-error
    gdbm-block-size-error
    gdbm-file-open-error
    gdbm-file-write-error
    gdbm-file-seek-error
    gdbm-file-read-error
    gdbm-bad-magic-number
    gdbm-empty-database
    gdbm-cant-be-reader
    gdbm-cant-be-writer
    gdbm-reader-cant-delete
    gdbm-reader-cant-store
    gdbm-reader-cant-reorganize
    gdbm-unknown-update
    gdbm-item-not-found
    gdbm-reorganize-failed
    gdbm-cannot-replace
    gdbm-illegal-data
    gdbm-option-already-set
    gdbm-illegal-option ;

<PRIVATE

: gdbm-errno ( -- n )
    [ gdbm_errno ] [ drop gdbm_errno_location int deref ] recover ;

: gdbm-throw ( -- * ) gdbm-errno gdbm-error number>enum throw ;

: check-error ( ret -- ) 0 = [ gdbm-throw ] unless ;

SYMBOL: current-dbf

: dbf ( -- dbf ) current-dbf get ;

: get-flag ( gdbm -- n )
    [ role>>   enum>number ]
    [ sync>>   GDBM_SYNC 0 ? ]
    [ nolock>> GDBM_NOLOCK 0 ? ]
    tri bitor bitor ;

: gdbm-open ( gdbm -- dbf )
    {
        [ name>> normalize-path ]
        [ block-size>> ] [ get-flag ] [ mode>> ]
    } cleave f gdbm_open [ gdbm-throw ] unless* ;

DESTRUCTOR: gdbm-close

: object>datum ( obj -- datum )
    object>bytes [ malloc-byte-array &free ] [ length ] bi
    datum boa ;

: datum>object* ( datum -- obj ? )
    [ dptr>> ] [ dsize>> ] bi over
    [ memory>byte-array bytes>object t ] [ drop f ] if ;

: gdbm-store ( key content flag -- )
    [
        [ dbf ] 3dip
        [ object>datum ] [ object>datum ] [ ] tri*
        gdbm_store check-error
    ] with-destructors ;

:: (gdbm-setopt) ( value option -- )
    [
        int heap-size dup malloc &free :> ( size ptr )
        value ptr 0 int set-alien-value
        dbf option ptr size gdbm_setopt check-error
    ] with-destructors ;

: gdbm-setopt ( value option -- )
    [ GDBM_CACHESIZE = [ >c-bool ] unless ] keep (gdbm-setopt) ;

PRIVATE>


: gdbm-info ( -- str ) gdbm_version ;

: gdbm-error-message ( error -- msg )
    enum>number gdbm_strerror ;

: gdbm-replace ( key content -- ) GDBM_REPLACE gdbm-store ;

: gdbm-insert ( key content -- ) GDBM_INSERT gdbm-store ;

: gdbm-delete ( key -- )
    [ dbf swap object>datum gdbm_delete check-error ]
    with-destructors ;

: gdbm-fetch* ( key -- content ? )
    [ dbf swap object>datum gdbm_fetch datum>object* ]
    with-destructors ;

: gdbm-first-key* ( -- key ? )
    [ dbf gdbm_firstkey datum>object* ] with-destructors ;

: gdbm-next-key* ( key -- next-key ? )
    [ dbf swap object>datum gdbm_nextkey datum>object* ]
    with-destructors ;

: gdbm-fetch ( key -- content/f ) gdbm-fetch* drop ;
: gdbm-first-key ( -- key/f ) gdbm-first-key* drop ;
: gdbm-next-key ( key -- key/f ) gdbm-next-key* drop ;

:: each-gdbm-key ( ... quot: ( ... key -- ... ) -- ... )
    gdbm-first-key*
    [ [ gdbm-next-key* ] [ quot keep ] do while ] when drop ; inline

: each-gdbm-value ( ... quot: ( ... value -- ... ) -- ... )
    [ gdbm-fetch ] prepose each-gdbm-key ; inline

: each-gdbm-record ( ... quot: ( ... key value -- ... ) -- ... )
    [ dup gdbm-fetch ] prepose each-gdbm-key ; inline

: gdbm-reorganize ( -- ) dbf gdbm_reorganize check-error ;

: gdbm-synchronize ( -- ) dbf gdbm_sync ;

: gdbm-exists? ( key -- ? )
    [ dbf swap object>datum gdbm_exists c-bool> ]
    with-destructors ;

: set-gdbm-cache-size ( size -- ) GDBM_CACHESIZE gdbm-setopt ;
: set-gdbm-sync-mode ( ? -- ) GDBM_SYNCMODE gdbm-setopt ;
: set-gdbm-block-pool ( ? -- ) GDBM_CENTFREE gdbm-setopt ;
: set-gdbm-block-merging ( ? -- ) GDBM_COALESCEBLKS gdbm-setopt ;

: gdbm-file-descriptor ( -- desc ) dbf gdbm_fdesc ;

: with-gdbm ( gdbm quot -- )
    '[
        _ gdbm-open &gdbm-close current-dbf
        _ with-variable
    ] with-destructors ; inline

:: with-gdbm-role ( name role quot -- )
    <gdbm> name >>name role >>role quot with-gdbm ; inline

: with-gdbm-reader ( name quot -- )
    reader swap with-gdbm-role ; inline

: with-gdbm-writer ( name quot -- )
    writer swap with-gdbm-role ; inline
