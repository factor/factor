! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors classes
combinators definitions effects fry generic generic.single
generic.standard hashtables io.binary io.encodings
io.streams.string kernel kernel.private math math.parser
namespaces parser sbufs sequences splitting splitting.private
strings vectors words ;
IN: hints

GENERIC: specializer-predicate ( spec -- quot )

M: class specializer-predicate predicate-def ;

M: object specializer-predicate '[ _ eq? ] ;

GENERIC: specializer-declaration ( spec -- class )

M: class specializer-declaration ;

M: object specializer-declaration class-of ;

: specializer ( word -- specializer )
    "specializer" word-prop ;

: make-specializer ( specs -- quot )
    dup length iota <reversed>
    [ (picker) 2array ] 2map
    [ drop object eq? not ] assoc-filter
    [ [ t ] ] [
        [ swap specializer-predicate append ] { } assoc>map
        [ ] [ swap [ f ] \ if 3array append [ ] like ] map-reduce
    ] if-empty ;

: specializer-cases ( quot specializer -- alist )
    dup [ array? ] all? [ 1array ] unless [
        [ nip make-specializer ]
        [ [ specializer-declaration ] map swap '[ _ declare @ ] ] 2bi
    ] with { } map>assoc ;

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

SYNTAX: HINTS:
    scan-object dup wrapper? [ wrapped>> ] when
    [ changed-definition ]
    [ subwords [ changed-definition ] each ]
    [ parse-definition { } like "specializer" set-word-prop ] tri ;

! Default specializers
{ last pop* pop } [
    { vector } "specializer" set-word-prop
] each

\ push { { vector } { sbuf } } "specializer" set-word-prop

\ last { { vector } } "specializer" set-word-prop

\ set-last { { object vector } } "specializer" set-word-prop

\ push-all
{ { string sbuf } { array vector } { byte-array byte-vector } }
"specializer" set-word-prop

\ append
{ { string string } { array array } }
"specializer" set-word-prop

\ prepend
{ { string string } { array array } }
"specializer" set-word-prop

\ subseq
{ { fixnum fixnum string } { fixnum fixnum array } }
"specializer" set-word-prop

\ reverse!
{ { string } { array } }
"specializer" set-word-prop

\ mismatch
{ string string }
"specializer" set-word-prop

\ >string { sbuf } "specializer" set-word-prop

\ >array { { vector } } "specializer" set-word-prop

\ >vector { { array } { vector } } "specializer" set-word-prop

\ >sbuf { string } "specializer" set-word-prop

\ split, { string string } "specializer" set-word-prop

\ member-eq? { array } "specializer" set-word-prop

\ member? { array } "specializer" set-word-prop

\ assoc-stack { vector } "specializer" set-word-prop

\ >le { { fixnum fixnum } { bignum fixnum } } "specializer" set-word-prop

\ >be { { bignum fixnum } { fixnum fixnum } } "specializer" set-word-prop

\ base> { string fixnum } "specializer" set-word-prop

M\ hashtable at* { { fixnum object } { word object } } "specializer" set-word-prop

M\ hashtable set-at { { object fixnum object } { object word object } } "specializer" set-word-prop

\ encode-string { string object object } "specializer" set-word-prop
