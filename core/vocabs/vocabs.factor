! Copyright (C) 2007, 2009 Eduardo Cavazos, Slava Pestov.
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

TUPLE: vocab-link name ;

C: <vocab-link> vocab-link

UNION: vocab-spec vocab vocab-link ;

GENERIC: vocab-name ( vocab-spec -- name )

M: vocab vocab-name name>> ;

M: vocab-link vocab-name name>> ;

M: string vocab-name ;

GENERIC: vocab ( vocab-spec -- vocab )

M: vocab vocab ;

M: object vocab ( name -- vocab ) vocab-name dictionary get at ;

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

SYMBOL: vocab-observers

GENERIC: vocabs-changed ( obj -- )

: add-vocab-observer ( obj -- )
    vocab-observers get push ;

: remove-vocab-observer ( obj -- )
    vocab-observers get delq ;

: notify-vocab-observers ( -- )
    vocab-observers get [ vocabs-changed ] each ;

: create-vocab ( name -- vocab )
    dictionary get [ <vocab> ] cache
    notify-vocab-observers ;

ERROR: no-vocab name ;

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

GENERIC: >vocab-link ( name -- vocab )

M: vocab-spec >vocab-link ;

M: string >vocab-link dup vocab [ ] [ <vocab-link> ] ?if ;

: forget-vocab ( vocab -- )
    dup words forget-all
    vocab-name dictionary get delete-at
    notify-vocab-observers ;

M: vocab-spec forget* forget-vocab ;

SYMBOL: load-vocab-hook ! ( name -- vocab )

: load-vocab ( name -- vocab ) load-vocab-hook get call( name -- vocab ) ;

PREDICATE: runnable-vocab < vocab
    vocab-main >boolean ;

INSTANCE: vocab-spec definition