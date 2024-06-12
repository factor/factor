! Copyright (C) 2007, 2009 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs definitions kernel namespaces sequences
sets sorting splitting strings ;
IN: vocabs

SYMBOL: dictionary

TUPLE: vocab < identity-tuple
name words
main help
source-loaded? docs-loaded? ;

! sources-loaded? and docs-loaded? slots could be
SYMBOLS: +parsing+ +done+ ;

: <vocab> ( name -- vocab )
    vocab new
        swap >>name
        H{ } clone >>words ;

<PRIVATE

: valid-vocab-name? ( name -- ? )
    dup string? [ [ ":/\\ \"" member? ] none? ] [ drop f ] if ;

PRIVATE>

ERROR: bad-vocab-name name ;

: check-vocab-name ( name -- name )
    dup valid-vocab-name? [ bad-vocab-name ] unless ;

TUPLE: vocab-link name ;

C: <vocab-link> vocab-link

UNION: vocab-spec vocab vocab-link ;

INSTANCE: vocab-spec definition-mixin

GENERIC: vocab-name ( vocab-spec -- name )

M: vocab vocab-name name>> ;

M: vocab-link vocab-name name>> ;

M: object vocab-name check-vocab-name ;

GENERIC: lookup-vocab ( vocab-spec -- vocab )

M: vocab lookup-vocab ;

M: object lookup-vocab vocab-name dictionary get at ;

ERROR: no-vocab-named name ;

: ?lookup-vocab ( vocab-spec -- vocab )
    [ lookup-vocab ] [ no-vocab-named ] ?unless ;

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

PREDICATE: runnable-vocab < vocab
    vocab-main >boolean ;

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
    dictionary get keys sort ;

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

M: object >vocab-link [ lookup-vocab ] [ <vocab-link> ] ?unless ;

<PRIVATE

: (forget-vocab) ( vocab -- )
    [ vocab-words forget-all ]
    [ vocab-name dictionary get delete-at ]
    [ notify-vocab-observers ] tri ;

PRIVATE>

: forget-vocab ( vocab -- )
    [ (forget-vocab) ] [
        vocab-name dup ".private" tail? [ drop ] [
            ".private" append (forget-vocab)
        ] if
    ] bi ;

M: vocab-spec forget* forget-vocab ;

SYMBOL: require-hook

<PRIVATE

SYMBOL: requiring

: with-requiring ( quot -- )
    requiring get [
        swap call
    ] [
        HS{ } clone dup requiring [ swap call ] with-variable
    ] if* ; inline

PRIVATE>

GENERIC: require ( object -- )

M: vocab require name>> require ;

M: vocab-link require name>> require ;

! When calling "foo.private" require, load "foo" instead, but
! only when "foo.private" does not exist. The reason for this is
! that stage1 bootstrap starts out with some .private vocabs
! that contain primitives, and loading the public vocabs would
! cause circularity issues.
M: string require
    [ ".private" ?tail ] 1check [ lookup-vocab not ] when [
        [
            dupd ?adjoin
            [ require-hook get call( name -- ) ] [ drop ] if
        ] with-requiring
    ] [ drop ] if ;

: require-all ( vocabs -- )
    [ require ] each ;

: load-vocab ( name -- vocab )
    [ require ] [ lookup-vocab ] bi ;

: ?load-vocab ( name -- vocab )
    [ require ] [ ?lookup-vocab ] bi ;
