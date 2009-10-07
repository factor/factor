! (c)Joe Groff bsd license
USING: accessors alien alien.c-types alien.data ascii
assocs byte-arrays classes.struct classes.tuple.private
combinators compiler.tree.debugger compiler.units destructors
io.encodings.utf8 io.pathnames io.streams.string kernel libc
literals math mirrors namespaces prettyprint
prettyprint.config see sequences specialized-arrays system
tools.test parser lexer eval layouts ;
FROM: math => float ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: char
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: ushort
IN: classes.struct.tests

SYMBOL: struct-test-empty

[ [ struct-test-empty { } define-struct-class ] with-compilation-unit ]
[ struct-must-have-slots? ] must-fail-with

STRUCT: struct-test-foo
    { x char }
    { y int initial: 123 }
    { z bool } ;

STRUCT: struct-test-bar
    { w ushort initial: HEX: ffff }
    { foo struct-test-foo } ;

[ 12 ] [ struct-test-foo heap-size ] unit-test
[ 12 ] [ struct-test-foo <struct> byte-length ] unit-test
[ 16 ] [ struct-test-bar heap-size ] unit-test
[ 123 ] [ struct-test-foo <struct> y>> ] unit-test
[ 123 ] [ struct-test-bar <struct> foo>> y>> ] unit-test

[ 1 2 3 t ] [
    1   2 3 t struct-test-foo <struct-boa>   struct-test-bar <struct-boa>
    {
        [ w>> ] 
        [ foo>> x>> ]
        [ foo>> y>> ]
        [ foo>> z>> ]
    } cleave
] unit-test

[ 7654 ] [ S{ struct-test-foo f 98 7654 f } y>> ] unit-test
[ 7654 ] [ S{ struct-test-foo { y 7654 } } y>> ] unit-test

[ {
    { "underlying" B{ 98 0 0 98 127 0 0 127 0 0 0 0 } }
    { { "x" char } 98            }
    { { "y" int  } HEX: 7F00007F }
    { { "z" bool } f             }
} ] [
    B{ 98 0 0 98 127 0 0 127 0 0 0 0 } struct-test-foo memory>struct
    make-mirror >alist
] unit-test

[ { { "underlying" f } } ] [
    f struct-test-foo memory>struct
    make-mirror >alist
] unit-test

[ 55 t ] [ S{ struct-test-foo { x 55 } } make-mirror { "x" "char" } swap at* ] unit-test
[ 55 t ] [ S{ struct-test-foo { y 55 } } make-mirror { "y" "int"  } swap at* ] unit-test
[ t  t ] [ S{ struct-test-foo { z t  } } make-mirror { "z" "bool" } swap at* ] unit-test
[ f  t ] [ S{ struct-test-foo { z f  } } make-mirror { "z" "bool" } swap at* ] unit-test
[ f  f ] [ S{ struct-test-foo } make-mirror { "nonexist" "bool" } swap at* ] unit-test
[ f  f ] [ S{ struct-test-foo } make-mirror "nonexist" swap at* ] unit-test
[ f  t ] [ f struct-test-foo memory>struct make-mirror "underlying" swap at* ] unit-test

[ S{ struct-test-foo { x 3 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ 3 { "x" "char" } ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 5 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ 5 { "y" "int" } ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z t } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ t { "z" "bool" } ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" "underlying" ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" "nonexist" ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror [ "nonsense" { "nonexist" "int" } ] dip set-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 123 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "y" "int" } swap delete-at ] keep
] unit-test

[ S{ struct-test-foo { x 0 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "x" "char" } swap delete-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror { "nonexist" "char" } swap delete-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror "underlying" swap delete-at ] keep
] unit-test

[ S{ struct-test-foo { x 1 } { y 2 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z f } }
    [ make-mirror "nonsense" swap delete-at ] keep
] unit-test

[ S{ struct-test-foo { x 0 } { y 123 } { z f } } ] [
    S{ struct-test-foo { x 1 } { y 2 } { z t } }
    [ make-mirror clear-assoc ] keep
] unit-test

UNION-STRUCT: struct-test-float-and-bits
    { f c:float }
    { bits uint } ;

[ 1.0 ] [ struct-test-float-and-bits <struct> 1.0 float>bits >>bits f>> ] unit-test
[ 4 ] [ struct-test-float-and-bits heap-size ] unit-test

[ 123 ] [ [ struct-test-foo malloc-struct &free y>> ] with-destructors ] unit-test

STRUCT: struct-test-string-ptr
    { x char* } ;

[ "hello world" ] [
    [
        struct-test-string-ptr <struct>
        "hello world" utf8 malloc-string &free >>x
        x>>
    ] with-destructors
] unit-test

[ "S{ struct-test-foo { x 0 } { y 7654 } { z f } }" ]
[
    [
        boa-tuples? off
        c-object-pointers? off
        struct-test-foo <struct> 7654 >>y [ pprint ] with-string-writer
    ] with-scope
] unit-test

[ "S@ struct-test-foo B{ 0 0 0 0 0 0 0 0 0 0 0 0 }" ]
[
    [
        c-object-pointers? on
        12 <byte-array> struct-test-foo memory>struct [ pprint ] with-string-writer
    ] with-scope
] unit-test

[ "S{ struct-test-foo f 0 7654 f }" ]
[
    [
        boa-tuples? on
        c-object-pointers? off
        struct-test-foo <struct> 7654 >>y [ pprint ] with-string-writer
    ] with-scope
] unit-test

[ "S@ struct-test-foo f" ]
[
    [
        c-object-pointers? off
        f struct-test-foo memory>struct [ pprint ] with-string-writer
    ] with-scope
] unit-test

[ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
STRUCT: struct-test-foo
    { x char initial: 0 } { y int initial: 123 } { z bool } ;
" ]
[ [ struct-test-foo see ] with-string-writer ] unit-test

[ "USING: alien.c-types classes.struct ;
IN: classes.struct.tests
UNION-STRUCT: struct-test-float-and-bits
    { f float initial: 0.0 } { bits uint initial: 0 } ;
" ]
[ [ struct-test-float-and-bits see ] with-string-writer ] unit-test

[ {
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
        { class integer }
        { type int }
    }
    T{ struct-slot-spec
        { name "z" }
        { offset 8 }
        { initial f }
        { type bool }
        { class object }
    }
} ] [ "struct-test-foo" c-type fields>> ] unit-test

[ {
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
        { class integer }
        { initial 0 }
    }
} ] [ "struct-test-float-and-bits" c-type fields>> ] unit-test

STRUCT: struct-test-equality-1
    { x int } ;
STRUCT: struct-test-equality-2
    { y int } ;

[ t ] [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-1 malloc-struct &free 5 >>x =
    ] with-destructors
] unit-test

[ f ] [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-2 malloc-struct &free 5 >>y =
    ] with-destructors
] unit-test

[ t ] [
    [
        struct-test-equality-1 <struct> 5 >>x
        struct-test-equality-1 malloc-struct &free 5 >>x
        [ hashcode ] bi@ =
    ] with-destructors
] unit-test

STRUCT: struct-test-array-slots
    { x int }
    { y ushort[6] initial: ushort-array{ 2 3 5 7 11 13 } }
    { z int } ;

[ 11 ] [ struct-test-array-slots <struct> y>> 4 swap nth ] unit-test

[ t ] [
    struct-test-array-slots <struct>
    [ y>> [ 8 3 ] dip set-nth ]
    [ y>> ushort-array{ 2 3 5 8 11 13 } sequence= ] bi
] unit-test

STRUCT: struct-test-optimization
    { x { int 3 } } { y int } ;

SPECIALIZED-ARRAY: struct-test-optimization

[ t ] [ [ struct-test-optimization memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test
[ t ] [
    [ 3 <direct-struct-test-optimization-array> third y>> ]
    { <tuple> <tuple-boa> memory>struct y>> } inlined?
] unit-test

[ t ] [ [ struct-test-optimization memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test

[ t ] [
    [ struct-test-optimization memory>struct x>> second ]
    { memory>struct x>> <direct-int-array> <tuple> <tuple-boa> } inlined?
] unit-test

[ f ] [ [ memory>struct y>> ] { memory>struct y>> } inlined? ] unit-test

[ t ] [
    [ struct-test-optimization <struct> struct-test-optimization <struct> [ x>> ] bi@ ]
    { x>> } inlined?
] unit-test

! Test cloning structs
STRUCT: clone-test-struct { x int } { y char[3] } ;

[ 1 char-array{ 9 1 1 } ] [
    clone-test-struct <struct>
    1 >>x char-array{ 9 1 1 } >>y
    clone
    [ x>> ] [ y>> >char-array ] bi
] unit-test

[ t 1 char-array{ 9 1 1 } ] [
    [
        clone-test-struct malloc-struct &free
        1 >>x char-array{ 9 1 1 } >>y
        clone
        [ >c-ptr byte-array? ] [ x>> ] [ y>> >char-array ] tri
    ] with-destructors
] unit-test

STRUCT: struct-that's-a-word { x int } ;

: struct-that's-a-word ( -- ) "OOPS" throw ;

[ -77 ] [ S{ struct-that's-a-word { x -77 } } clone x>> ] unit-test

! Interactive parsing of struct slot definitions
[
    "USE: classes.struct IN: classes.struct.tests STRUCT: unexpected-eof-test" <string-reader>
    "struct-class-test-1" parse-stream
] [ error>> error>> unexpected-eof? ] must-fail-with

! S{ with non-struct type
[
    "USE: classes.struct IN: classes.struct.tests TUPLE: not-a-struct ; S{ not-a-struct }"
    eval( -- value )
] must-fail

! Subclassing a struct class should not be allowed
[
    "USE: classes.struct IN: classes.struct.tests STRUCT: a-struct { x int } ; TUPLE: not-a-struct < a-struct ;"
    eval( -- )
] must-fail

! Remove c-type when struct class is forgotten
[ ] [
    "USE: classes.struct IN: classes.struct.tests TUPLE: a-struct ;" eval( -- )
] unit-test

[ f ] [ "a-struct" c-types get key? ] unit-test

STRUCT: bit-field-test
    { a uint bits: 12 }
    { b int bits: 2 }
    { c char } ;
