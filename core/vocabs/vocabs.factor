! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs strings kernel sorting namespaces
sequences definitions ;
IN: vocabs

SYMBOL: dictionary

TUPLE: vocab < identity-tuple
name words
main help
source-loaded? docs-loaded? ;

! sources-loaded? slot is one of these three
SYMBOL: +parsing+
SYMBOL: +running+
SYMBOL: +done+

: <vocab> ( name -- vocab )
    \ vocab new
        swap >>name
        H{ } clone >>words ;

GENERIC: vocab-name ( vocab-spec -- name )

GENERIC: vocab ( vocab-spec -- vocab )

M: vocab vocab ;

M: object vocab ( name -- vocab ) vocab-name dictionary get at ;

M: vocab vocab-name name>> ;

M: string vocab-name ;

GENERIC: vocab-words ( vocab-spec -- words )

M: vocab vocab-words words>> ;

M: object vocab-words vocab vocab-words ;

M: f vocab-words ;

GENERIC: vocab-help ( vocab-spec -- help )

M: vocab vocab-help help>> ;

M: object vocab-help vocab vocab-help ;

M: f vocab-help ;

GENERIC: vocab-main ( vocab-spec -- main )

M: vocab vocab-main main>> ;

M: object vocab-main vocab vocab-main ;

M: f vocab-main ;

: create-vocab ( name -- vocab )
    dictionary get [ <vocab> ] cache ;

ERROR: no-vocab name ;

SYMBOL: load-vocab-hook ! ( name -- )

: load-vocab ( name -- vocab )
    dup load-vocab-hook get call vocab ;

: vocabs ( -- seq )
    dictionary get keys natural-sort ;

: words ( vocab -- seq )
    vocab-words values ;

: all-words ( -- seq )
    dictionary get values [ words ] map concat ;

: words-named ( str -- seq )
    dictionary get values
    [ vocab-words at ] with map
    sift ;

: child-vocab? ( prefix name -- ? )
    2dup = pick empty? or
    [ 2drop t ] [ swap CHAR: . suffix head? ] if ;

: child-vocabs ( vocab -- seq )
    vocab-name vocabs [ child-vocab? ] with filter ;

TUPLE: vocab-link name ;

: <vocab-link> ( name -- vocab-link )
    vocab-link boa ;

M: vocab-link hashcode* name>> hashcode* ;

M: vocab-link vocab-name name>> ;

UNION: vocab-spec vocab vocab-link ;

GENERIC: >vocab-link ( name -- vocab )

M: vocab-spec >vocab-link ;

M: string >vocab-link dup vocab [ ] [ <vocab-link> ] ?if ;

: forget-vocab ( vocab -- )
    dup words forget-all
    vocab-name dictionary get delete-at ;

M: vocab-spec forget* forget-vocab ;
