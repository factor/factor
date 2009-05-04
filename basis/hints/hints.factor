! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser words definitions kernel sequences assocs arrays
kernel.private fry combinators accessors vectors strings sbufs
byte-arrays byte-vectors io.binary io.streams.string splitting math
math.parser generic generic.single generic.standard classes
hashtables namespaces ;
IN: hints

GENERIC: specializer-predicate ( spec -- quot )

M: class specializer-predicate "predicate" word-prop ;

M: object specializer-predicate '[ _ eq? ] ;

GENERIC: specializer-declaration ( spec -- class )

M: class specializer-declaration ;

M: object specializer-declaration class ;

: make-specializer ( specs -- quot )
    dup length <reversed>
    [ (picker) 2array ] 2map
    [ drop object eq? not ] assoc-filter
    [ [ t ] ] [
        [ swap specializer-predicate append ] { } assoc>map
        [ ] [ swap [ f ] \ if 3array append [ ] like ] map-reduce
    ] if-empty ;

: specializer-cases ( quot word -- default alist )
    dup [ array? ] all? [ 1array ] unless [
        [ make-specializer ] keep
        [ specializer-declaration ] map '[ _ declare ] pick append
    ] { } map>assoc ;

: specialize-quot ( quot specializer -- quot' )
    specializer-cases alist>quot ;

! compiler.tree.propagation.inlining sets this to f
SYMBOL: specialize-method?

t specialize-method? set-global

: method-declaration ( method -- quot )
    [ "method-generic" word-prop dispatch# object <array> ]
    [ "method-class" word-prop ]
    bi prefix [ declare ] curry [ ] like ;

: specialize-method ( quot method -- quot' )
    [ specialize-method? get [ method-declaration prepend ] [ drop ] if ]
    [ "method-generic" word-prop "specializer" word-prop ] bi
    [ specialize-quot ] when* ;

: standard-method? ( method -- ? )
    dup method-body? [
        "method-generic" word-prop standard-generic?
    ] [ drop f ] if ;

: specialized-def ( word -- quot )
    [ def>> ] keep
    dup generic? [ drop ] [
        [ dup standard-method? [ specialize-method ] [ drop ] if ]
        [ "specializer" word-prop [ specialize-quot ] when* ]
        bi
    ] if ;

: specialized-length ( specializer -- n )
    dup [ array? ] all? [ first ] when length ;

SYNTAX: HINTS:
    scan-object
    [ changed-definition ]
    [ parse-definition { } like "specializer" set-word-prop ] bi ;

! Default specializers
{ first first2 first3 first4 }
[ { array } "specializer" set-word-prop ] each

{ peek pop* pop } [
    { vector } "specializer" set-word-prop
] each

\ push { { vector } { sbuf } } "specializer" set-word-prop

\ push-all
{ { string sbuf } { array vector } { byte-array byte-vector } }
"specializer" set-word-prop

\ append
{ { string string } { array array } }
"specializer" set-word-prop

\ subseq
{ { fixnum fixnum string } { fixnum fixnum array } }
"specializer" set-word-prop

\ reverse-here
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

\ memq? { array } "specializer" set-word-prop

\ member? { array } "specializer" set-word-prop

\ assoc-stack { vector } "specializer" set-word-prop

\ >le { { fixnum fixnum } { bignum fixnum } } "specializer" set-word-prop

\ >be { { bignum fixnum } { fixnum fixnum } } "specializer" set-word-prop

\ base> { string fixnum } "specializer" set-word-prop

M\ hashtable at* { { fixnum object } { word object } } "specializer" set-word-prop

M\ hashtable set-at { { object fixnum object } { object word object } } "specializer" set-word-prop
