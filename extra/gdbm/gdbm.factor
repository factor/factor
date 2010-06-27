! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors
alien.enums classes.struct combinators destructors gdbm.ffi io.backend
kernel libc locals math namespaces sequences serialize strings ;
IN: gdbm

TUPLE: gdbm
    { name string }
    { block-size integer }
    { role initial: wrcreat }
    { sync boolean }
    { nolock boolean }
    { mode integer initial: OCT: 644 } ;

: <gdbm> ( -- gdbm ) gdbm new ;


<PRIVATE

: gdbm-throw ( -- * ) gdbm_errno throw ;

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
    datum <struct-boa> ;

: datum>object* ( datum -- obj ? )
    [ dptr>> ] [ dsize>> ] bi over
    [ memory>byte-array bytes>object t ] [ drop f ] if ;

: gdbm-store ( key content flag -- )
    [
        { [ dbf ] [ object>datum ] [ object>datum ] [ ] } spread
        gdbm_store check-error
    ] with-destructors ;

:: (setopt) ( value option -- )
    [
        int heap-size dup malloc &free :> ( size ptr )
        value ptr 0 int set-alien-value
        dbf option ptr size gdbm_setopt check-error
    ] with-destructors ;

: setopt ( value option -- )
    [ GDBM_CACHESIZE = [ >c-bool ] unless ] keep (setopt) ;

PRIVATE>


: gdbm-info ( -- str ) gdbm_version ;

: gdbm-error-message ( error -- msg ) gdbm_strerror ;

: replace ( key content -- ) GDBM_REPLACE gdbm-store ;
: insert ( key content -- ) GDBM_INSERT gdbm-store ;

: delete ( key -- )
    [ dbf swap object>datum gdbm_delete check-error ]
    with-destructors ;

: fetch* ( key -- content ? )
    [ dbf swap object>datum gdbm_fetch datum>object* ]
    with-destructors ;

: first-key* ( -- key ? )
    [ dbf gdbm_firstkey datum>object* ] with-destructors ;

: next-key* ( key -- next-key ? )
    [ dbf swap object>datum gdbm_nextkey datum>object* ]
    with-destructors ;

: fetch ( key -- content/f ) fetch* drop ;
: first-key ( -- key/f ) first-key* drop ;
: next-key ( key -- key/f ) next-key* drop ;

: reorganize ( -- ) dbf gdbm_reorganize check-error ;

: synchronize ( -- ) dbf gdbm_sync ;

: exists? ( key -- ? )
    [ dbf swap object>datum gdbm_exists c-bool> ]
    with-destructors ;

: set-cache-size ( size -- ) GDBM_CACHESIZE setopt ;
: set-sync-mode ( ? -- ) GDBM_SYNCMODE setopt ;
: set-block-pool ( ? -- ) GDBM_CENTFREE setopt ;
: set-block-merging ( ? -- ) GDBM_COALESCEBLKS setopt ;

: gdbm-file-descriptor ( -- desc ) dbf gdbm_fdesc ;

: with-gdbm ( gdbm quot -- )
    [ gdbm-open &gdbm-close current-dbf set ] prepose curry
    [ with-scope ] curry with-destructors ; inline
