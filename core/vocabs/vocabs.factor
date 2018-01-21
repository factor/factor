! Copyright (C) 2007, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs definitions kernel namespaces
sequences sorting splitting strings ;
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
    vocab new
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

GENERIC: lookup-vocab ( vocab-spec -- vocab )

M: vocab lookup-vocab ;

M: object lookup-vocab vocab-name dictionary get at ;

GENERIC: vocab-words-assoc ( vocab-spec -- assoc/f )

M: vocab vocab-words-assoc words>> ;

M: object vocab-words-assoc lookup-vocab vocab-words-assoc ;

M: f vocab-words-assoc ;

GENERIC: vocab-help ( vocab-spec -- help )

M: vocab vocab-help help>> ;

M: object vocab-help lookup-vocab vocab-help ;

M: f vocab-help ;

GENERIC: vocab-main ( vocab-spec -- main )

M: vocab vocab-main main>> ;

M: object vocab-main lookup-vocab vocab-main ;

M: f vocab-main ;

SYMBOL: vocab-observers

GENERIC: vocab-changed ( vocab obj -- )

: add-vocab-observer ( obj -- )
    vocab-observers get push ;

: remove-vocab-observer ( obj -- )
    vocab-observers get remove-eq! drop ;

: notify-vocab-observers ( vocab -- )
    vocab-observers get [ vocab-changed ] with each ;

: create-vocab ( name -- vocab )
    check-vocab-name dictionary get [ <vocab> ] cache
    dup notify-vocab-observers ;

ERROR: no-vocab name ;

: loaded-vocab-names ( -- seq )
    dictionary get keys natural-sort ;

: vocab-words ( vocab-spec -- seq )
    vocab-words-assoc values ;

: all-words ( -- seq )
    dictionary get values [ vocab-words ] map concat ;

: words-named ( str -- seq )
    dictionary get
    [ values [ vocab-words-assoc at ] with map sift ]
    [
        [ ":" split1 swap ] dip at
        [ vocab-words-assoc at [ suffix ] when* ] [ drop ] if*
    ] 2bi ;

: child-vocab? ( prefix name -- ? )
    swap [ drop t ] [
        2dup = [ 2drop t ] [
            2dup head? [
                length swap ?nth CHAR: . =
            ] [ 2drop f ] if
        ] if
    ] if-empty ;

: loaded-child-vocab-names ( vocab-spec -- seq )
    vocab-name loaded-vocab-names [ child-vocab? ] with filter ;

GENERIC: >vocab-link ( name -- vocab )

M: vocab-spec >vocab-link ;

M: object >vocab-link dup lookup-vocab [ ] [ <vocab-link> ] ?if ;

: forget-vocab ( vocab -- )
    [ vocab-words forget-all ]
    [ vocab-name dictionary get delete-at ]
    [ notify-vocab-observers ] tri ;

M: vocab-spec forget* forget-vocab ;

SYMBOL: require-hook

PREDICATE: runnable-vocab < vocab
    vocab-main >boolean ;

INSTANCE: vocab-spec definition-mixin

GENERIC: require ( object -- )

M: vocab require name>> require ;

M: vocab-link require name>> require ;

! When calling "foo.private" require, load "foo" instead, but
! only when "foo.private" does not exist. The reason for this is
! that stage1 bootstrap starts out with some .private vocabs
! that contain primitives, and loading the public vocabs would
! cause circularity issues.
M: string require
    [ ".private" ?tail ] keep swap [ lookup-vocab not ] when
    [ require-hook get call( name -- ) ] [ drop ] if ;

: load-vocab ( name -- vocab )
    [ require ] [ lookup-vocab ] bi ;
