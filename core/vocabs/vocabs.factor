! Copyright (C) 2007, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs definitions kernel namespaces sequences
sets sorting splitting strings ;
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

ERROR: bad-vocab-name name ;

: check-vocab-name ( name -- name )
    dup string? [ bad-vocab-name ] unless
    dup [ ":/\\ " member? ] any? [ bad-vocab-name ] when ;

TUPLE: vocab-link name ;

C: <vocab-link> vocab-link

UNION: vocab-spec vocab vocab-link ;

GENERIC: vocab-name ( vocab-spec -- name )

M: vocab vocab-name name>> ;

M: vocab-link vocab-name name>> ;

M: object vocab-name check-vocab-name ;

: vocab-name* ( vocab-spec -- name )
    vocab-name ".private" ?tail drop ;

: private-vocab? ( vocab -- ? )
    vocab-name ".private" tail? ;

GENERIC: lookup-vocab ( vocab-spec -- vocab )

M: vocab lookup-vocab ;

M: object lookup-vocab ( name -- vocab ) vocab-name dictionary get at ;

GENERIC: vocab-words ( vocab-spec -- words )

M: vocab vocab-words words>> ;

M: object vocab-words lookup-vocab vocab-words ;

M: f vocab-words ;

GENERIC: vocab-help ( vocab-spec -- help )

M: vocab vocab-help help>> ;

M: object vocab-help lookup-vocab vocab-help ;

M: f vocab-help ;

GENERIC: vocab-main ( vocab-spec -- main )

M: vocab vocab-main main>> ;

M: object vocab-main lookup-vocab vocab-main ;

M: f vocab-main ;

SYMBOL: vocab-observers

GENERIC: vocabs-changed ( obj -- )

: add-vocab-observer ( obj -- )
    vocab-observers get push ;

: remove-vocab-observer ( obj -- )
    vocab-observers get remove-eq! drop ;

: notify-vocab-observers ( -- )
    vocab-observers get [ vocabs-changed ] each ;

: create-vocab ( name -- vocab )
    check-vocab-name
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

M: object >vocab-link dup lookup-vocab [ ] [ <vocab-link> ] ?if ;

: forget-vocab ( vocab -- )
    [ words forget-all ]
    [ vocab-name dictionary get delete-at ] bi
    notify-vocab-observers ;

M: vocab-spec forget* forget-vocab ;

SYMBOL: require-hook

PREDICATE: runnable-vocab < vocab
    vocab-main >boolean ;

INSTANCE: vocab-spec definition

: call-require-hook ( name -- )
    require-hook get call( name -- ) ;

GENERIC: require ( object -- )

M: vocab require name>> require ;
M: vocab-link require name>> require ;

! When calling "foo.private" require, load "foo" instead, but only when
! "foo.private" does not exist. The reason for this is that stage1 bootstrap
! starts out with some .private vocabs that contain primitives, and
! loading the public vocabs would cause circularity issues.
M: string require ( vocab -- )
    dup ".private" ?tail [
        over lookup-vocab
        [ 2drop ]
        [ nip call-require-hook ]
        if
    ] [
        nip call-require-hook
    ] if ;

: load-vocab ( name -- vocab )
    [ require ] [ lookup-vocab ] bi ;
