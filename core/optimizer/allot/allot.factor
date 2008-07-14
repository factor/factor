! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences sequences.private classes.tuple
classes.tuple.private kernel effects words quotations namespaces
definitions math math.order layouts alien.accessors
slots.private arrays byte-arrays inference.dataflow
inference.known-words inference.state optimizer.inlining
optimizer.backend ;
IN: optimizer.allot

! Expand memory allocation primitives into simpler constructs
! to simplify the backend.

: first-input ( #call -- obj ) dup in-d>> first node-literal ;

: (tuple) ( layout -- tuple ) "BUG: missing (tuple) intrinsic" throw ;

\ (tuple) { tuple-layout } { tuple } <effect> set-primitive-effect
\ (tuple) make-flushable

! if the input to new is a literal tuple class, we can expand it
: literal-new? ( #call -- ? )
    first-input tuple-class? ;

: new-quot ( class -- quot )
    dup all-slots 1 tail ! delegate slot
    [ [ initial>> literalize , ] each literalize , \ boa , ] [ ] make ;

: expand-new ( #call -- node )
    dup first-input
    [ +inlined+ depends-on ] [ new-quot ] bi
    f splice-quot ;

\ new {
    { [ dup literal-new? ] [ expand-new ] }
} define-optimizers

: tuple-boa-quot ( layout -- quot )
    [
        dup ,
        [ nip (tuple) ] %
        size>> 1 - [ 3 + ] map <reversed>
        [ [ set-slot ] curry [ keep ] curry % ] each
        [ f over 2 set-slot ] %
    ] [ ] make ;

: expand-tuple-boa ( #call -- node )
    dup in-d>> peek value-literal tuple-boa-quot f splice-quot ;

\ <tuple-boa> {
    { [ t ] [ expand-tuple-boa ] }
} define-optimizers

: (array) ( n -- array ) "BUG: missing (array) intrinsic" throw ;

\ (array) { integer } { array } <effect> set-primitive-effect
\ (array) make-flushable

: <array>-quot ( n -- quot )
    [
        dup ,
        [ nip (array) ] %
        [ \ 2dup , , [ swap set-array-nth ] % ] each
        \ nip ,
    ] [ ] make ;

: literal-<array>? ( #call -- ? )
    first-input dup integer? [ 0 32 between? ] [ drop f ] if ;

: expand-<array> ( #call -- node )
    dup first-input <array>-quot f splice-quot ;

\ <array> {
    { [ dup literal-<array>? ] [ expand-<array> ] }
} define-optimizers

: (byte-array) ( n -- byte-array ) "BUG: missing (byte-array) intrinsic" throw ;

\ (byte-array) { integer } { byte-array } <effect> set-primitive-effect
\ (byte-array) make-flushable

: bytes>cells ( m -- n ) cell align cell /i ;

: <byte-array>-quot ( n -- quot )
    [
        dup ,
        [ nip (byte-array) ] %
        bytes>cells [ cell * ] map
        [ [ 0 over ] % , [ set-alien-unsigned-cell ] % ] each
    ] [ ] make ;

: literal-<byte-array>? ( #call -- ? )
    first-input dup integer? [ 0 128 between? ] [ drop f ] if ;

: expand-<byte-array> ( #call -- node )
    dup first-input <byte-array>-quot f splice-quot ;

\ <byte-array> {
    { [ dup literal-<byte-array>? ] [ expand-<byte-array> ] }
} define-optimizers
