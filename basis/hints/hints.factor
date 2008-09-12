! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser words definitions kernel sequences assocs arrays
kernel.private fry combinators accessors vectors strings sbufs
byte-arrays byte-vectors io.binary io.streams.string splitting
math generic generic.standard generic.standard.engines ;
IN: hints

: (make-specializer) ( class picker -- quot )
    swap "predicate" word-prop append ;

: make-specializer ( classes -- quot )
    dup length <reversed>
    [ (picker) 2array ] 2map
    [ drop object eq? not ] assoc-filter
    [ [ t ] ] [
        [ (make-specializer) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if-empty ;

: specializer-cases ( quot word -- default alist )
    dup [ array? ] all? [ 1array ] unless [
        [ make-specializer ] keep
        '[ _ declare ] pick append
    ] { } map>assoc ;

: method-declaration ( method -- quot )
    [ "method-generic" word-prop dispatch# object <array> ]
    [ "method-class" word-prop ]
    bi prefix ;

: specialize-method ( quot method -- quot' )
    method-declaration '[ _ declare ] prepend ;

: specialize-quot ( quot specializer -- quot' )
    specializer-cases alist>quot ;

: standard-method? ( method -- ? )
    dup method-body? [
        "method-generic" word-prop standard-generic?
    ] [ drop f ] if ;

: specialized-def ( word -- quot )
    dup def>> swap {
        { [ dup standard-method? ] [ specialize-method ] }
        {
            [ dup "specializer" word-prop ]
            [ "specializer" word-prop specialize-quot ]
        }
        [ drop ]
    } cond ;

: specialized-length ( specializer -- n )
    dup [ array? ] all? [ first ] when length ;

: HINTS:
    scan-word
    [ redefined ]
    [ parse-definition "specializer" set-word-prop ] bi ;
    parsing

! Default specializers
{ first first2 first3 first4 }
[ { array } "specializer" set-word-prop ] each

{ peek pop* pop push } [
    { vector } "specializer" set-word-prop
] each

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

\ find-last-sep { string sbuf } "specializer" set-word-prop

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
