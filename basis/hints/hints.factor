! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors classes
combinators definitions fry generic generic.single
generic.standard hashtables kernel kernel.private math
math.parser parser sbufs sequences splitting strings vectors
words ;
IN: hints

GENERIC: specializer-predicate ( spec -- quot )

M: class specializer-predicate '[ _ instance? ] ;

M: object specializer-predicate '[ _ eq? ] ;

GENERIC: specializer-declaration ( spec -- class )

M: class specializer-declaration ;

M: object specializer-declaration class-of ;

: specializer ( word -- specializer )
    "specializer" word-prop ;

: make-specializer ( specs -- quot )
    dup length <iota> <reversed>
    [ (picker) 2array ] 2map
    [ object eq? ] reject-keys
    [ [ t ] ] [
        [ swap specializer-predicate append ] { } assoc>map
        [ ] [ swap [ f ] \ if 3array [ ] append-as ] map-reduce
    ] if-empty ;

: specializer-cases ( quot specializer -- alist )
    dup [ array? ] all? [ 1array ] unless [
        [ nip make-specializer ]
        [ [ specializer-declaration ] map swap '[ _ declare @ ] ] 2bi
    ] with map>alist ;

: specialize-quot ( quot specializer -- quot' )
    [ drop ] [ specializer-cases ] 2bi alist>quot ;

: method-declaration ( method -- quot )
    [ "method-generic" word-prop dispatch# object <array> ]
    [ "method-class" word-prop ]
    bi prefix [ declare ] curry [ ] like ;

: specialize-method ( quot method -- quot' )
    [ method-declaration prepend ]
    [ "method-generic" word-prop ] bi
    specializer [ specialize-quot ] when* ;

: standard-method? ( method -- ? )
    dup method? [
        "method-generic" word-prop standard-generic?
    ] [ drop f ] if ;

: specialized-def ( word -- quot )
    [ def>> ] keep
    dup generic? [ drop ] [
        [ dup standard-method? [ specialize-method ] [ drop ] if ]
        [ specializer [ specialize-quot ] when* ]
        bi
    ] if ;

: specialized-length ( specializer -- n )
    dup [ array? ] all? [ first ] when length ;

ERROR: cannot-specialize word specializer ;

: set-specializer ( word specializer -- )
    over inline-recursive? [ cannot-specialize ] when
    "specializer" set-word-prop ;

SYNTAX: HINTS:
    scan-object dup wrapper? [ wrapped>> ] when
    [ changed-definition ]
    [ subwords [ changed-definition ] each ]
    [ parse-definition { } like set-specializer ] tri ;

! Default specializers
{ pop* pop push last } [
    { vector } set-specializer
] each

\ set-last { { object vector } } set-specializer

\ push-all
{ { string sbuf } { array vector } { byte-array byte-vector } }
set-specializer

{ append prepend } [
    { { string string } { array array } }
    set-specializer
] each

{ suffix prefix } [
    { { string object } { array object } }
    set-specializer
] each

\ subseq
{ { fixnum fixnum string } { fixnum fixnum array } }
set-specializer

\ reverse!
{ { string } { array } }
set-specializer

\ mismatch
{ string string }
set-specializer

\ >string { sbuf } set-specializer

\ >array { { vector } } set-specializer

\ >vector { { array } { vector } } set-specializer

\ >sbuf { string } set-specializer

\ split { string string } set-specializer

\ member? { { array } { string } } set-specializer

\ member-eq? { { array } { string } } set-specializer

\ assoc-stack { vector } set-specializer

\ base> { string fixnum } set-specializer

M\ hashtable at*
{ { fixnum object } { word object } }
set-specializer

M\ hashtable set-at
{ { object fixnum object } { object word object } }
set-specializer
