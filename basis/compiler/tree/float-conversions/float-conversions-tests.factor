USING: accessors compiler.test compiler.tree compiler.tree.builder
compiler.tree.combinators compiler.tree.optimizer kernel kernel.private
layouts math math.private sequences tools.test ;
IN: compiler.tree.float-conversions.tests

: has-fixnum>float? ( quot -- ? )
    build-tree optimize-tree [
        dup #call? [ word>> \ fixnum>float eq? ] [ drop f ] if
    ] contains-node? ;

! #1556: both branch-produced literals and literals selected by ?.
{ f } [ [ [ 3 ] [ 4 ] if fixnum>float ] has-fixnum>float? ] unit-test
{ f } [ [ { float object } declare 1 -1 ? - ] has-fixnum>float? ] unit-test
{ 3.0 } [ t [ [ 3 ] [ 4 ] if fixnum>float ] compile-call ] unit-test
{ 4.0 } [ f [ [ 3 ] [ 4 ] if fixnum>float ] compile-call ] unit-test
{ 9.0 } [ 10.0 t [ { float object } declare 1 -1 ? - ] compile-call ] unit-test
{ 11.0 } [ 10.0 f [ { float object } declare 1 -1 ? - ] compile-call ] unit-test

! Shared values must retain their integer representation.
{ t } [ [ [ 3 ] [ 4 ] if dup fixnum>float ] has-fixnum>float? ] unit-test
{ 3 3.0 } [ t [ [ 3 ] [ 4 ] if dup fixnum>float ] compile-call ] unit-test
{ 4 4.0 } [ f [ [ 3 ] [ 4 ] if dup fixnum>float ] compile-call ] unit-test
! A single input can feed multiple outputs of a phi.
{ t } [ [ [ 3 dup ] [ 4 dup ] if fixnum>float ] has-fixnum>float? ] unit-test
{ 3 3.0 } [ t [ [ 3 dup ] [ 4 dup ] if fixnum>float ] compile-call ] unit-test
{ 4 4.0 } [ f [ [ 3 dup ] [ 4 dup ] if fixnum>float ] compile-call ] unit-test
{ t } [ [ { fixnum object } declare [ ] [ drop 4 ] if fixnum>float ] has-fixnum>float? ] unit-test

! Inexact conversion remains at runtime to honor rounding modes and flags.
cell 8 = [
    { t } [ [ [ 0x20000000000001 ] [ 4 ] if fixnum>float ] has-fixnum>float? ] unit-test
] when
