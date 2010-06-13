! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors
classes.struct combinators destructors gdbm.ffi io.backend kernel libc
literals math namespaces sequences serialize strings ;
IN: gdbm

: object>datum ( obj -- datum )
    object>bytes [ malloc-byte-array &free ] [ length ] bi
    datum <struct-boa> ;

: datum>object* ( datum -- obj ? )
    [ dptr>> ] [ dsize>> ] bi over
    [ memory>byte-array bytes>object t ] [ drop f ] if ;

SYMBOL: current-dbf

: dbf ( -- dbf ) current-dbf get ;

TUPLE: gdbm
    { name       string  }
    { block-size integer }
    { flags      integer initial: $ GDBM_WRCREAT }
    { mode       integer initial: OCT: 644 } ;

DESTRUCTOR: gdbm-close

ERROR: gdbm-error errno msg ;

: gdbm-throw ( -- * ) gdbm_errno dup gdbm_strerror gdbm-error ;

: check-error ( ret -- ) 0 = [ gdbm-throw ] unless ;

: gdbm-open ( gdbm -- dbf )
    {
        [ name>> normalize-path ]
        [ block-size>> ] [ flags>> ] [ mode>> ]
    } cleave f gdbm_open [ gdbm-throw ] unless* ;

: gdbm-store ( key content flag -- )
    [
        { [ dbf ] [ object>datum ] [ object>datum ] [ ] } spread
        gdbm_store check-error
    ] with-destructors ;

: gdbm-replace ( key content -- ) GDBM_REPLACE gdbm-store ;

: gdbm-insert ( key content -- ) GDBM_INSERT gdbm-store ;

: gdbm-fetch* ( key -- content ? )
    [ dbf swap object>datum gdbm_fetch datum>object* ]
    with-destructors ;

: gdbm-fetch ( key -- content/f ) gdbm-fetch* drop ;

: gdbm-delete ( key -- )
    [ dbf swap object>datum gdbm_delete check-error ]
    with-destructors ;

: gdbm-firstkey* ( -- key ? )
    [ dbf gdbm_firstkey datum>object* ] with-destructors ;

: gdbm-firstkey ( -- key/f ) gdbm-firstkey* drop ;

: gdbm-nextkey* ( key -- key ? )
    [ dbf swap object>datum gdbm_nextkey datum>object* ]
    with-destructors ;

: gdbm-nextkey ( key -- key/f ) gdbm-nextkey* drop ;

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
