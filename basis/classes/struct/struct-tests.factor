! Copyright (C) 2009, 2010, 2011 Joe Groff, Slava Pestov, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.syntax
assocs byte-arrays classes classes.private classes.struct
classes.struct.prettyprint.private classes.tuple
classes.tuple.parser classes.tuple.private combinators
compiler.tree.debugger compiler.units definitions delegate
destructors eval generic generic.single io.encodings.utf8
io.streams.string kernel layouts lexer libc literals math
mirrors namespaces parser prettyprint prettyprint.config see
sequences specialized-arrays specialized-arrays.private
system tools.test vocabs ;
FROM: math => float ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: char
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: ushort
IN: classes.struct.tests

SYMBOL: struct-test-empty

[ [ struct-test-empty { } define-struct-class ] with-compilation-unit ]
[ struct-must-have-slots? ] must-fail-with

STRUCT: struct-test-readonly
    { x uint read-only } ;

{ S{ struct-test-readonly f 10 } } [
    10 struct-test-readonly <struct-boa>
] unit-test

STRUCT: struct-test-foo
    { x char }
    { y int initial: 123 }
    { z bool } ;

STRUCT: struct-test-bar
    { w ushort initial: 0xffff }
    { foo struct-test-foo } ;

{ 12 } [ struct-test-foo heap-size ] unit-test
{ 12 } [ struct-test-foo <struct> byte-length ] unit-test
{ t } [ [ struct-test-foo new ] { <struct> } inlined? ] unit-test
{ t } [ [ struct-test-foo boa ] { <struct-boa> } inlined? ] unit-test
{ 16 } [ struct-test-bar heap-size ] unit-test
{ 123 } [ struct-test-foo <struct> y>> ] unit-test
{ 123 } [ struct-test-bar <struct> foo>> y>> ] unit-test

{ 1 2 3 t } [
    1   2 3 t struct-test-foo <struct-boa>   struct-test-bar <struct-boa>
    {
        [ w>> ]
        [ foo>> x>> ]
        [ foo>> y>> ]
        [ foo>> z>> ]
    } cleave
] unit-test

{ 7654 } [ S{ struct-test-foo f 98 7654 f } y>> ] unit-test
{ 7654 } [ S{ struct-test-foo { y 7654 } } y>> ] unit-test

{ {
    { "underlying" B{ 98 0 0 98 127 0 0 127 0 0 0 0 } }
    { { "x" char } 98            }
    { { "y" int  } 0x7F00007F }
    { { "z" bool } f             }
} } [
    B{ 98 0 0 98 127 0 0 127 0 0 0 0 } struct-test-foo memory>struct
    make-mirror >alist
] unit-test

{ { { "underlying" f } } } [
    f struct-test-foo memory>struct
    make-mirror >alist
] unit-test

{ 55 t } [ S{ struct-test-foo { x 55 } } make-mirror { "x" "char" } ?of ] unit-test
{ 55 t } [ S{ struct-test-foo { y 55 } } make-mirror { "y" "int"  } ?of ] unit-test
{ t  t } [ S{ struct-test-foo { z t  } } make-mirror { "z" "bool" } ?of ] unit-test
{ f  t } [ S{ struct-test-foo { z f  } } make-mirror { "z" "bool" } ?of ] unit-test
{ { "nonexist" "bool" } f } [ S{ struct-test-foo } make-mirror { "nonexist" "bool" } ?of ] unit-test
{ "nonexist" f } [ S{ struct-test-foo } make-mirror "nonexist" ?of ] unit-test
{ f  t } [ f struct-test-foo memory>struct make-mirror "underlying" ?of ] unit-test

{ S{ struct-test-foo { x 3 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ 3 { "x" "char" } ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 5 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ 5 { "y" "int" } ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z t } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ t { "z" "bool" } ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" "underlying" ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" "nonexist" ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" { "nonexist" "int" } ] dip set-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 123 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "y" "int" } swap delete-at ] keep
] unit-test

{ S{ struct-test-foo { x 0 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "x" "char" } swap delete-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "nonexist" "char" } swap delete-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror "underlying" swap delete-at ] keep
] unit-test

{ S{ struct-test-foo { x 1 } { y 2 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror "nonsense" swap delete-at ] keep
] unit-test

{ S{ struct-test-foo { x 0 } { y 123 } { z f } } } [
    S{ struct-test-foo { x 1 } { y 2 } { z t } }
    [ make-mirror clear-assoc ] keep
] unit-test

{ POSTPONE: STRUCT: }
[ struct-test-foo struct-definer-word ] unit-test

UNION-STRUCT: struct-test-float-and-bits
    { f c:float }
    { bits uint } ;

{ 1.0 } [ struct-test-float-and-bits <struct> 1.0 float>bits >>bits f>> ] unit-test
{ 4 } [ struct-test-float-and-bits heap-size ] unit-test

{ 123 } [ [ struct-test-foo malloc-struct &free y>> ] with-destructors ] unit-test

{ POSTPONE: UNION-STRUCT: }
[ struct-test-float-and-bits struct-definer-word ] unit-test

STRUCT: struct-test-string-ptr
    { x c-string } ;

{ "hello world" } [
    [
        struct-test-string-ptr <struct>
        "hello world" utf8 malloc-string &free >>x
        x>>
    ] with-destructors
] unit-test

{ "S{ struct-test-foo { x 0 } { y 7654 } { z f } }" }
[
    H{ { boa-tuples? f } { c-object-pointers? f } } [
        struct-test-foo <struct> 7654 >>y unparse
    ] with-variables
] unit-test

{ "S@ struct-test-foo B{ 0 0 0 0 0 0 0 0 0 0 0 0 }" }
[
    H{ { c-object-pointers? t } } [
        12 <byte-array> struct-test-foo memory>struct unparse
    ] with-variables
] unit-test

{ "S{ struct-test-foo f 0 7654 f }" }
[
    H{ { boa-tuples? t } { c-object-pointers? f } } [
        struct-test-foo <struct> 7654 >>y unparse
    ] with-variables
] unit-test

{ "S@ struct-test-foo f" }
[
    H{ { c-object-pointers? f } } [
        f struct-test-foo memory>struct unparse
    ] with-variables
] unit-test

: with-default-string-writer ( quot -- str )
    64 margin [ with-string-writer ] with-variable ; inline

{ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
STRUCT: struct-test-foo
    { x char initial: 0 } { y int initial: 123 } { z bool } ;
" }
[ [ struct-test-foo see ] with-default-string-writer ] unit-test

{ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
UNION-STRUCT: struct-test-float-and-bits
    { f float initial: 0.0 } { bits uint initial: 0 } ;
" }
[ [ struct-test-float-and-bits see ] with-default-string-writer ] unit-test

{ {
    T{ struct-slot-spec
        { name "x" }
        { offset 0 }
        { initial 0 }
        { class fixnum }
        { type char }
    }
    T{ struct-slot-spec
        { name "y" }
        { offset 4 }
        { initial 123 }
        { class $[ cell 4 = integer fixnum ? ] }
        { type int }
    }
    T{ struct-slot-spec
        { name "z" }
        { offset 8 }
        { initial f }
        { type bool }
        { class object }
    }
} } [ struct-test-foo lookup-c-type fields>> ] unit-test

{ {
    T{ struct-slot-spec
        { name "f" }
        { offset 0 }
        { type c:float }
        { class float }
        { initial 0.0 }
    }
    T{ struct-slot-spec
        { name "bits" }
        { offset 0 }
        { type uint }
        { class $[ cell 4 = integer fixnum ? ] }
        { initial 0 }
    }
} } [ struct-test-float-and-bits lookup-c-type fields>> ] unit-test

STRUCT: struct-test-equality-1
    { x int } ;
STRUCT: struct-test-equality-2
    { y int } ;


{ t } [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-1 malloc-struct &free 5 >>x =
    ] with-destructors
] unit-test

{ f } [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-2 malloc-struct &free 5 >>y =
    ] with-destructors
] unit-test

STRUCT: struct-test-array-slots
    { x int }
    { y ushort[6] initial: ushort-array{ 2 3 5 7 11 13 } }
    { z int } ;

{ 11 } [ struct-test-array-slots <struct> y>> 4 swap nth ] unit-test

{ t } [
    struct-test-array-slots <struct>
    [ y>> [ 8 3 ] dip set-nth ]
    [ y>> ushort-array{ 2 3 5 8 11 13 } sequence= ] bi
] unit-test

STRUCT: struct-test-optimization
    { x { int 3 } } { y int } ;

SPECIALIZED-ARRAY: struct-test-optimization

{ t } [ [ struct-test-optimization memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test
{ t } [
    [ 3 struct-test-optimization <c-direct-array> third y>> ]
    { <tuple> <tuple-boa> memory>struct y>> } inlined?
] unit-test

{ t } [ [ struct-test-optimization memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test

{ t } [
    [ struct-test-optimization memory>struct x>> second ]
    { memory>struct x>> int <c-direct-array> <tuple> <tuple-boa> } inlined?
] unit-test

{ f } [ [ memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test

{ t } [
    [ struct-test-optimization <struct> struct-test-optimization <struct> [ x>> ] bi@ ]
    { x>> } inlined?
] unit-test

{ } [
    [
        struct-test-optimization specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Test cloning structs
STRUCT: clone-test-struct { x int } { y char[3] } ;

{ 1 char-array{ 9 1 1 } } [
    clone-test-struct <struct>
    1 >>x char-array{ 9 1 1 } >>y
    clone
    [ x>> ] [ y>> char >c-array ] bi
] unit-test

{ t 1 char-array{ 9 1 1 } } [
    [
        clone-test-struct malloc-struct &free
        1 >>x char-array{ 9 1 1 } >>y
        clone
        [ >c-ptr byte-array? ] [ x>> ] [ y>> char >c-array ] tri
    ] with-destructors
] unit-test

STRUCT: struct-that's-a-word { x int } ;

: struct-that's-a-word ( -- ) "OOPS" throw ;

{ -77 } [ S{ struct-that's-a-word { x -77 } } clone x>> ] unit-test

! Interactive parsing of struct slot definitions
[
    "USE: classes.struct IN: classes.struct.tests STRUCT: unexpected-eof-test" <string-reader>
    "struct-class-test-1" parse-stream
] [ error>> error>> unexpected-eof? ] must-fail-with

[
    "USING: alien.c-types classes.struct ; IN: classes.struct.tests STRUCT: struct-test-duplicate-slots { x uint } { x uint } ;" eval( -- )
] [ error>> duplicate-slot-names? ] must-fail-with

[
    "USING: alien.c-types classes.struct ; IN: classes.struct.tests STRUCT: struct-test-duplicate-slots { x uint } { x float } ;" eval( -- )
] [ error>> duplicate-slot-names? ] must-fail-with

! S{ with non-struct type
[
    "USE: classes.struct IN: classes.struct.tests TUPLE: not-a-struct ; S{ not-a-struct }"
    eval( -- value )
] [ error>> no-method? ] must-fail-with

! Subclassing a struct class should not be allowed
[
    "USING: alien.c-types classes.struct ; IN: classes.struct.tests STRUCT: a-struct { x int } ; TUPLE: not-a-struct < a-struct ;"
    eval( -- )
] [ error>> bad-superclass? ] must-fail-with

! Changing a superclass into a struct should reset the subclass
TUPLE: will-become-struct ;

TUPLE: a-subclass < will-become-struct ;

{ f } [ will-become-struct struct-class? ] unit-test

{ will-become-struct } [ a-subclass superclass-of ] unit-test

{ } [ "IN: classes.struct.tests USING: classes.struct alien.c-types ; STRUCT: will-become-struct { x int } ;" eval( -- ) ] unit-test

{ t } [ will-become-struct struct-class? ] unit-test

{ tuple } [ a-subclass superclass-of ] unit-test

STRUCT: bit-field-test
    { a uint bits: 12 }
    { b int bits: 2 }
    { c char } ;

{ S{ bit-field-test f 0 0 0 } } [ bit-field-test <struct> ] unit-test
{ S{ bit-field-test f 1 -2 3 } } [ bit-field-test <struct> 1 >>a 2 >>b 3 >>c ] unit-test
{ 4095 } [ bit-field-test <struct> 8191 >>a a>> ] unit-test
{ 1 } [ bit-field-test <struct> 1 >>b b>> ] unit-test
{ -2 } [ bit-field-test <struct> 2 >>b b>> ] unit-test
{ 1 } [ bit-field-test <struct> 257 >>c c>> ] unit-test
{ 3 } [ bit-field-test heap-size ] unit-test

STRUCT: referent
    { y int } ;
STRUCT: referrer
    { x referent* } ;

{ 57 } [
    [
        referrer <struct>
            referent malloc-struct &free
                57 >>y
            >>x
        x>> y>>
    ] with-destructors
] unit-test

STRUCT: self-referent
    { x self-referent* }
    { y int } ;

{ 75 } [
    [
        self-referent <struct>
            self-referent malloc-struct &free
                75 >>y
            >>x
        x>> y>>
    ] with-destructors
] unit-test

C-TYPE: forward-referent
STRUCT: backward-referent
    { x forward-referent* }
    { y int } ;
STRUCT: forward-referent
    { x backward-referent* }
    { y int } ;

{ 41 } [
    [
        forward-referent <struct>
            backward-referent malloc-struct &free
                41 >>y
            >>x
        x>> y>>
    ] with-destructors
] unit-test

{ 14 } [
    [
        backward-referent <struct>
            forward-referent malloc-struct &free
                14 >>y
            >>x
        x>> y>>
    ] with-destructors
] unit-test

cpu ppc? [
    STRUCT: ppc-align-test-1
        { x longlong }
        { y int } ;

    [ 16 ] [ ppc-align-test-1 heap-size ] unit-test

    STRUCT: ppc-align-test-2
        { y int }
        { x longlong } ;

    [ 16 ] [ ppc-align-test-2 heap-size ] unit-test
    [ 8 ] [ "x" ppc-align-test-2 offset-of ] unit-test
] when

STRUCT: struct-test-delegate
    { a int } ;
STRUCT: struct-test-delegator
    { del struct-test-delegate }
    { b int } ;
CONSULT: struct-test-delegate struct-test-delegator del>> ;

{ S{ struct-test-delegator f S{ struct-test-delegate f 7 } 8 } } [
    struct-test-delegator <struct>
        7 >>a
        8 >>b
] unit-test

SPECIALIZED-ARRAY: void*

STRUCT: silly-array-field-test { x int*[3] } ;

{ t } [ silly-array-field-test <struct> x>> void*-array? ] unit-test

! Packed structs
PACKED-STRUCT: packed-struct-test
    { d c:int }
    { e c:short }
    { f c:int }
    { g c:char }
    { h c:int } ;

{ 15 } [ packed-struct-test heap-size ] unit-test

{ 0 } [ "d" packed-struct-test offset-of ] unit-test
{ 4 } [ "e" packed-struct-test offset-of ] unit-test
{ 6 } [ "f" packed-struct-test offset-of ] unit-test
{ 10 } [ "g" packed-struct-test offset-of ] unit-test
{ 11 } [ "h" packed-struct-test offset-of ] unit-test

{ POSTPONE: PACKED-STRUCT: }
[ packed-struct-test struct-definer-word ] unit-test

STRUCT: struct-1 { a c:int } ;
PACKED-STRUCT: struct-1-packed { a c:int } ;
UNION-STRUCT: struct-1-union { a c:int } ;

{ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
STRUCT: struct-1 { a int initial: 0 } ;
" }
[ \ struct-1 [ see ] with-default-string-writer ] unit-test
{ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
PACKED-STRUCT: struct-1-packed { a int initial: 0 } ;
" }
[ \ struct-1-packed [ see ] with-default-string-writer ] unit-test
{ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
STRUCT: struct-1-union { a int initial: 0 } ;
" }
[ \ struct-1-union [ see ] with-default-string-writer ] unit-test

! Bug #206
STRUCT: going-to-redefine { a uint } ;
{ } [
    "IN: classes.struct.tests TUPLE: going-to-redefine b ;" eval( -- )
] unit-test
{ f } [ \ going-to-redefine \ clone ?lookup-method ] unit-test
{ f } [ \ going-to-redefine \ struct-slot-values ?lookup-method ] unit-test

! Test reset-class on structs, which should forget all the accessors, clone, and struct-slot-values
STRUCT: some-accessors { aaa uint } { bbb int } ;
{ } [ [ \ some-accessors reset-class ] with-compilation-unit ] unit-test
{ f } [ \ some-accessors \ a>> ?lookup-method ] unit-test
{ f } [ \ some-accessors \ a<< ?lookup-method ] unit-test
{ f } [ \ some-accessors \ b>> ?lookup-method ] unit-test
{ f } [ \ some-accessors \ b<< ?lookup-method ] unit-test
{ f } [ \ some-accessors \ clone ?lookup-method ] unit-test
{ f } [ \ some-accessors \ struct-slot-values ?lookup-method ] unit-test

<< \ some-accessors forget >>

! hashcode tests
${ 64-bit? 0x31e9d070e63 -0x2f8f19d ? } [ struct-test-equality-1 new hashcode ] unit-test

{ t } [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-1 malloc-struct &free 5 >>x
        [ hashcode ] same?
    ] with-destructors
] unit-test

! Same slots, so the hashcode should be the same.
{ t } [
    B{ 98 0 33 0 1 1 1 1 1 1 1 1 } struct-test-foo memory>struct
    B{ 98 0 22 0 1 1 1 1 1 1 1 1 } struct-test-foo memory>struct
    [ hashcode ] same?
] unit-test

! Equality tests
{ t } [
    B{ 98 0 33 0 1 1 1 1 1 1 1 1 } struct-test-foo memory>struct
    B{ 98 0 22 0 1 1 1 1 1 1 1 1 } struct-test-foo memory>struct
    =
] unit-test
