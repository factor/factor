! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private tools.test math math.partial-dispatch
prettyprint math.private accessors slots.private sequences
sequences.private strings sbufs compiler.tree.builder
compiler.tree.normalization compiler.tree.debugger alien.accessors
layouts combinators byte-arrays arrays ;
IN: compiler.tree.modular-arithmetic.tests

: test-modular-arithmetic ( quot -- quot' )
    cleaned-up-tree nodes>quot ;

{ [ >R >fixnum R> >fixnum fixnum+fast ] }
[ [ { integer integer } declare + >fixnum ] test-modular-arithmetic ] unit-test

{ [ +-integer-integer dup >fixnum ] }
[ [ { integer integer } declare + dup >fixnum ] test-modular-arithmetic ] unit-test

{ [ >R >fixnum R> >fixnum fixnum+fast 4 fixnum*fast ] }
[ [ { integer integer } declare + 4 * >fixnum ] test-modular-arithmetic ] unit-test

TUPLE: declared-fixnum { x fixnum } ;

{ t } [
    [ { declared-fixnum } declare [ 1 + ] change-x ]
    { + } inlined?
    ! XXX: As of .97, we do a bounds check and throw an error on
    ! overflow, so we no longer convert fixnum+ to fixnum+fast.
    ! If this is too big a regression, we can revert it.
    ! { + fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ { declared-fixnum } declare x>> drop ]
    { slot } inlined?
] unit-test

{ f } [
    [ { integer } declare -63 shift 4095 bitand ]
    \ shift inlined?
] unit-test

{ t } [
    [ { integer } declare 127 bitand 3 + ]
    { + +-integer-fixnum bitand } inlined?
] unit-test

{ f } [
    [ { integer } declare 127 bitand 3 + ]
    { integer>fixnum } inlined?
] unit-test

{ t } [
    [
        { integer } declare
        dup 0 >= [
            615949 * 797807 + 20 2^ mod dup 19 2^ -
        ] [ dup ] if
    ] { * + shift mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

{ t } [
    [
        { fixnum } declare
        615949 * 797807 + 20 2^ mod dup 19 2^ -
    ] { >fixnum } inlined?
] unit-test

{ t } [
    [
        { integer } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

{ t } [
    [
        { fixnum } declare <iota> 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- >fixnum } inlined?
] unit-test

{ t } [
    [ { string sbuf } declare ] \ push-all def>> append \ + inlined?
] unit-test

{ t } [
    [ { string sbuf } declare ] \ push-all def>> append \ fixnum+ inlined?
] unit-test

{ t } [
    [ { string sbuf } declare ] \ push-all def>> append \ >fixnum inlined?
] unit-test

{ t } [
    [
        { integer } declare <iota> [ 256 mod ] map
    ] { mod fixnum-mod } inlined?
] unit-test

{ f } [
    [
        256 mod
    ] { mod fixnum-mod } inlined?
] unit-test

{ f } [
    [
        >fixnum 256 mod
    ] { mod fixnum-mod } inlined?
] unit-test

{ f } [
    [
        dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

{ t } [
    [
        { integer } declare dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

{ t } [
    [
        { integer } declare 256 rem
    ] { mod fixnum-mod } inlined?
] unit-test

{ t } [
    [
        { iota } declare [ 256 rem ] map
    ] { mod fixnum-mod rem } inlined?
] unit-test

{ [ drop 0 ] }
[ [ >integer 1 rem ] test-modular-arithmetic ] unit-test

{ [ drop 0 ] }
[ [ >integer 1 mod ] test-modular-arithmetic ] unit-test

{ [ >fixnum 255 >R R> fixnum-bitand ] }
[ [ >integer 256 rem ] test-modular-arithmetic ] unit-test

{ t } [
    [ { fixnum fixnum } declare + [ 1 + >fixnum ] [ 2 + >fixnum ] bi ]
    { >fixnum } inlined?
] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-unsigned-1 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-unsigned-1 ] test-modular-arithmetic ] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-unsigned-2 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-unsigned-2 ] test-modular-arithmetic ] unit-test

cell {
    { 4 [ [ [ "COMPLEX SHUFFLE" fixnum+ "COMPLEX SHUFFLE" set-alien-unsigned-4 ] ] ] }
    { 8 [ [ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-unsigned-4 ] ] ] }
} case
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-unsigned-4 ] test-modular-arithmetic ] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+ "COMPLEX SHUFFLE" set-alien-unsigned-8 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-unsigned-8 ] test-modular-arithmetic ] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-signed-1 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-signed-1 ] test-modular-arithmetic ] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-signed-2 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-signed-2 ] test-modular-arithmetic ] unit-test

cell {
    { 4 [ [ [ "COMPLEX SHUFFLE" fixnum+ "COMPLEX SHUFFLE" set-alien-signed-4 ] ] ] }
    { 8 [ [ [ "COMPLEX SHUFFLE" fixnum+fast "COMPLEX SHUFFLE" set-alien-signed-4 ] ] ] }
} case
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-signed-4 ] test-modular-arithmetic ] unit-test

{ [ "COMPLEX SHUFFLE" fixnum+ "COMPLEX SHUFFLE" set-alien-signed-8 ] }
[ [ [ { fixnum fixnum } declare + ] 2dip set-alien-signed-8 ] test-modular-arithmetic ] unit-test

{ t } [ [ { fixnum byte-array } declare [ + ] with map ] { + fixnum+ >fixnum } inlined? ] unit-test

{ t } [
    [ 0 10 <byte-array> 10 [ 1 pick 0 + >fixnum pick set-nth-unsafe [ 1 + >fixnum ] dip ] times ]
    { >fixnum } inlined?
] unit-test

{ f } [ [ + >fixnum ] { >fixnum } inlined? ] unit-test

{ t } [
    [ >integer [ >fixnum ] [ >fixnum ] bi ]
    { >integer } inlined?
] unit-test

{ f } [
    [ >integer [ >fixnum ] [ >fixnum ] bi ]
    { >fixnum } inlined?
] unit-test

{ t } [
    [ >integer [ 2 + >fixnum ] [ 3 + >fixnum ] bi ]
    { >integer } inlined?
] unit-test

{ f } [
    [ >integer [ 2 + >fixnum ] [ 3 + >fixnum ] bi ]
    { >fixnum } inlined?
] unit-test

{ t } [
    [ >integer [ >fixnum ] [ >fixnum ] bi ]
    { >integer } inlined?
] unit-test

{ f } [
    [ >bignum [ >fixnum ] [ >fixnum ] bi ]
    { >fixnum } inlined?
] unit-test

{ t } [
    [ >bignum [ >fixnum ] [ >fixnum ] bi ]
    { >bignum } inlined?
] unit-test

{ f } [
    [ [ { fixnum } declare 2 fixnum+ ] dip [ >fixnum 2 - ] [ ] if ]
    { fixnum+ } inlined?
] unit-test

{ t } [
    [ { fixnum boolean } declare [ 1 + ] [ "HI" throw ] if >fixnum ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ { fixnum boolean } declare [ 1 + ] [ drop 5 ] if >fixnum ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ { fixnum boolean } declare [ 1 + ] [ 2 + ] if >fixnum ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ [ [ 1 ] [ 4 ] if ] } [
    [ [ 1.5 ] [ 4 ] if >fixnum ] test-modular-arithmetic
] unit-test

{ [ [ 1 ] [ 2 ] if ] } [
    [ [ 1.5 ] [ 2.3 ] if >fixnum ] test-modular-arithmetic
] unit-test

{ f } [
    [ { fixnum fixnum boolean } declare [ [ 3 * ] [ 1 + ] dip ] [ [ 4 - ] [ 2 + ] dip ] if >fixnum ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ 0 1000 [ 1 + dup >fixnum . ] times drop ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ { fixnum } declare 3 + [ 1000 ] dip [ >fixnum . ] curry times ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ t } [
    [ 0 1000 [ 1 + ] times >fixnum ]
    { fixnum+ >fixnum } inlined?
] unit-test

{ f } [
    [ f >fixnum ]
    { >fixnum } inlined?
] unit-test

{ f } [
    [ [ >fixnum ] 2dip set-alien-unsigned-1 ]
    { >fixnum } inlined?
] unit-test

{ t } [
    [ { fixnum } declare 123 >bignum bitand >fixnum ]
    { >bignum fixnum>bignum bignum-bitand } inlined?
] unit-test

! Shifts
{ t } [
    [
        [ 0 ] 2dip { array } declare [
            hashcode* >fixnum swap [
                [ -2 shift ] [ 5 shift ] bi
                + +
            ] keep bitxor >fixnum
        ] with each
    ] { + bignum+ fixnum-shift bitxor bignum-bitxor } inlined?
] unit-test
