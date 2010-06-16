! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors assocs
biassocs classes.struct combinators destructors gdbm.ffi io.backend
kernel libc literals locals math namespaces sequences serialize
strings ;
IN: gdbm

TUPLE: gdbm
    { name       string  }
    { block-size integer }
    { flags      integer initial: $ GDBM_WRCREAT }
    { mode       integer initial: OCT: 644 } ;

SINGLETONS:
    gdbm-no-error             gdbm-malloc-error
    gdbm-block-size-error     gdbm-file-open-error
    gdbm-file-write-error     gdbm-file-seek-error
    gdbm-file-read-error      gdbm-bad-magic-number
    gdbm-empty-database       gdbm-cant-be-reader
    gdbm-cant-be-writer       gdbm-reader-cant-delete
    gdbm-reader-cant-store    gdbm-reader-cant-reorganize
    gdbm-unknown-update       gdbm-item-not-found
    gdbm-reorganize-failed    gdbm-cannot-replace
    gdbm-illegal-data         gdbm-option-already-set
    gdbm-illegal-option ;

ERROR: gdbm-unknown-error error ;


<PRIVATE

: error-table ( -- table )
    {
        {  0 gdbm-no-error               }
        {  1 gdbm-malloc-error           }
        {  2 gdbm-block-size-error       }
        {  3 gdbm-file-open-error        }
        {  4 gdbm-file-write-error       }
        {  5 gdbm-file-seek-error        }
        {  6 gdbm-file-read-error        }
        {  7 gdbm-bad-magic-number       }
        {  8 gdbm-empty-database         }
        {  9 gdbm-cant-be-reader         }
        { 10 gdbm-cant-be-writer         }
        { 11 gdbm-reader-cant-delete     }
        { 12 gdbm-reader-cant-store      }
        { 13 gdbm-reader-cant-reorganize }
        { 14 gdbm-unknown-update         }
        { 15 gdbm-item-not-found         }
        { 16 gdbm-reorganize-failed      }
        { 17 gdbm-cannot-replace         }
        { 18 gdbm-illegal-data           }
        { 19 gdbm-option-already-set     }
        { 20 gdbm-illegal-option         }
    } >biassoc ;

: error>code ( error -- code )
    dup error-table value-at [ ] [ gdbm-unknown-error ] ?if ;

: code>error ( code -- error ) error-table at ;

: gdbm-throw ( -- * ) gdbm_errno code>error throw ;

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


: gdbm-error-message ( error -- msg ) error>code gdbm_strerror ;

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

<PRIVATE

:: (gdbm-setopt) ( option value -- )
    [
        int heap-size dup malloc &free :> ( size ptr )
        value ptr 0 int set-alien-value
        dbf option ptr size gdbm_setopt check-error
    ] with-destructors ;

PRIVATE>

: gdbm-setopt ( option value -- )
    over GDBM_CACHESIZE = [ >c-bool ] unless (gdbm-setopt) ;

: gdbm-fdesc ( -- desc ) dbf gdbm_fdesc ;

: with-gdbm ( gdbm quot -- )
    [ gdbm-open &gdbm-close current-dbf set ] prepose curry
    [ with-scope ] curry with-destructors ; inline
