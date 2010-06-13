! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors
classes.struct combinators destructors gdbm.ffi io.backend kernel libc
literals math namespaces sequences serialize strings ;
IN: gdbm

TUPLE: gdbm
    { name       string  }
    { block-size integer }
    { flags      integer initial: $ GDBM_WRCREAT }
    { mode       integer initial: OCT: 644 } ;

ERROR: gdbm-error errno msg ;


<PRIVATE

: gdbm-throw ( -- * ) gdbm_errno dup gdbm_strerror gdbm-error ;

: check-error ( ret -- ) 0 = [ gdbm-throw ] unless ;

SYMBOL: current-dbf

: dbf ( -- dbf ) current-dbf get ;

: gdbm-open ( gdbm -- dbf )
    {
        [ name>> normalize-path ]
        [ block-size>> ] [ flags>> ] [ mode>> ]
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

PRIVATE>


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

: gdbm-next-key* ( key -- key ? )
    [ dbf swap object>datum gdbm_nextkey datum>object* ]
    with-destructors ;

: gdbm-fetch ( key -- content/f ) gdbm-fetch* drop ;
: gdbm-first-key ( -- key/f ) gdbm-first-key* drop ;
: gdbm-next-key ( key -- key/f ) gdbm-next-key* drop ;

: gdbm-reorganize ( -- ) dbf gdbm_reorganize check-error ;

: gdbm-sync ( -- ) dbf gdbm_sync ;

: gdbm-exists ( key -- ? )
    [ dbf swap object>datum gdbm_exists c-bool> ]
    with-destructors ;

! : gdbm-setopt ( option value size -- ret ) ;

: gdbm-fdesc ( -- desc ) dbf gdbm_fdesc ;

: with-gdbm ( gdbm quot -- )
    [ gdbm-open &gdbm-close current-dbf set ] prepose curry
    [ with-scope ] curry with-destructors ; inline
