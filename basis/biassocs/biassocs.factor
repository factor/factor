! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel assocs accessors summary hashtables ;
IN: biassocs

TUPLE: biassoc from to ;

: <biassoc> ( exemplar -- biassoc )
    [ clone ] [ clone ] bi biassoc boa ;

: <bihash> ( -- biassoc )
    H{ } <biassoc> ;

M: biassoc assoc-size from>> assoc-size ;

M: biassoc at* from>> at* ; inline

M: biassoc value-at* to>> at* ; inline

: set-at-once ( value key assoc -- )
    [ key? ] 2guard [ 3drop ] [ set-at ] if ;

M: biassoc set-at
    [ from>> set-at ] [ swapd to>> set-at-once ] 3bi ;

ERROR: no-biassoc-deletion ;

M: no-biassoc-deletion summary
    drop "biassocs do not support deletion" ;

M: biassoc delete-at
    no-biassoc-deletion ;

M: biassoc >alist from>> >alist ;

M: biassoc keys from>> keys ;

M: biassoc values from>> values ;

M: biassoc clear-assoc
    [ from>> clear-assoc ] [ to>> clear-assoc ] bi ;

M: biassoc new-assoc
    drop [ <hashtable> ] [ <hashtable> ] bi biassoc boa ;

INSTANCE: biassoc assoc

: >biassoc ( assoc -- biassoc )
    T{ biassoc } assoc-clone-like ;

M: biassoc clone
    [ from>> ] [ to>> ] bi [ clone ] bi@ biassoc boa ;
