! (c)Joe Groff bsd license
USING: accessors alien.c-types alien.libraries
alien.structs.fields alien.syntax classes.struct combinators
destructors io.encodings.utf8 io.pathnames io.streams.string
kernel libc literals math multiline namespaces prettyprint
prettyprint.config see system tools.test ;
IN: classes.struct.tests

<<
: libfactor-ffi-tests-path ( -- string )
    "resource:" (normalize-path)
    {
        { [ os winnt? ]  [ "libfactor-ffi-test.dll" ] }
        { [ os macosx? ] [ "libfactor-ffi-test.dylib" ] }
        { [ os unix?  ]  [ "libfactor-ffi-test.so" ] }
    } cond append-path ;

"f-cdecl" libfactor-ffi-tests-path "cdecl" add-library

"f-stdcall" libfactor-ffi-tests-path "stdcall" add-library
>>

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

UNION-STRUCT: struct-test-float-and-bits
    { f float }
    { bits uint } ;

[ 1.0 ] [ struct-test-float-and-bits <struct> 1.0 float>bits >>bits f>> ] unit-test
[ 4 ] [ struct-test-float-and-bits heap-size ] unit-test

[ ] [ [ struct-test-foo malloc-struct &free drop ] with-destructors ] unit-test

STRUCT: struct-test-string-ptr
    { x char* } ;

[ "hello world" ] [
    [
        struct-test-string-ptr <struct>
        "hello world" utf8 malloc-string &free >>x
        x>>
    ] with-destructors
] unit-test

[ "S{ struct-test-foo { y 7654 } }" ]
[
    f boa-tuples?
    [ struct-test-foo <struct> 7654 >>y [ pprint ] with-string-writer ]
    with-variable
] unit-test

[ "S{ struct-test-foo f 0 7654 f }" ]
[
    t boa-tuples?
    [ struct-test-foo <struct> 7654 >>y [ pprint ] with-string-writer ]
    with-variable
] unit-test

[ <" USING: classes.struct ;
IN: classes.struct.tests
STRUCT: struct-test-foo
    { x char initial: 0 } { y int initial: 123 } { z bool } ;
"> ]
[ [ struct-test-foo see ] with-string-writer ] unit-test

[ <" USING: classes.struct ;
IN: classes.struct.tests
UNION-STRUCT: struct-test-float-and-bits
    { f float initial: 0.0 } { bits uint initial: 0 } ;
"> ]
[ [ struct-test-float-and-bits see ] with-string-writer ] unit-test

[ {
    T{ field-spec
        { name "x" }
        { offset 0 }
        { type "char" }
        { reader x>> }
        { writer (>>x) }
    }
    T{ field-spec
        { name "y" }
        { offset 4 }
        { type "int" }
        { reader y>> }
        { writer (>>y) }
    }
    T{ field-spec
        { name "z" }
        { offset 8 }
        { type "bool" }
        { reader z>> }
        { writer (>>z) }
    }
} ] [ "struct-test-foo" c-type fields>> ] unit-test

[ {
    T{ field-spec
        { name "f" }
        { offset 0 }
        { type "float" }
        { reader f>> }
        { writer (>>f) }
    }
    T{ field-spec
        { name "bits" }
        { offset 0 }
        { type "uint" }
        { reader bits>> }
        { writer (>>bits) }
    }
} ] [ "struct-test-float-and-bits" c-type fields>> ] unit-test

STRUCT: struct-test-ffi-foo
    { x int }
    { y int } ;

LIBRARY: f-cdecl
FUNCTION: int ffi_test_11 ( int a, struct-test-ffi-foo b, int c ) ;

[ 14 ] [ 1 2 3 struct-test-ffi-foo <struct-boa> 4 ffi_test_11 ] unit-test
