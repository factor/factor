! (c)Joe Groff bsd license
USING: accessors alien.c-types alien.structs.fields classes.c-types
classes.struct combinators io.streams.string kernel libc literals math
multiline namespaces prettyprint prettyprint.config see tools.test ;
IN: classes.struct.tests

STRUCT: struct-test-foo
    { x char }
    { y int initial: 123 }
    { z boolean } ;

STRUCT: struct-test-bar
    { w ushort initial: HEX: ffff }
    { foo struct-test-foo } ;

[ 12 ] [ struct-test-foo heap-size ] unit-test
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
    { f single-float }
    { bits uint } ;

[ 1.0 ] [ struct-test-float-and-bits <struct> 1.0 float>bits >>bits f>> ] unit-test
[ 4 ] [ struct-test-float-and-bits heap-size ] unit-test

[ ] [ struct-test-foo malloc-struct free ] unit-test

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

[ <" USING: classes.c-types classes.struct kernel ;
IN: classes.struct.tests
STRUCT: struct-test-foo
    { x char initial: 0 } { y int initial: 123 }
    { z boolean initial: f } ;
"> ]
[ [ struct-test-foo see ] with-string-writer ] unit-test

[ <" USING: classes.c-types classes.struct ;
IN: classes.struct.tests
UNION-STRUCT: struct-test-float-and-bits
    { f single-float initial: 0.0 } { bits uint initial: 0 } ;
"> ]
[ [ struct-test-float-and-bits see ] with-string-writer ] unit-test

[ {
    T{ field-spec
        { name "x" }
        { offset 0 }
        { type $[ char c-type ] }
        { reader x>> }
        { writer (>>x) }
    }
    T{ field-spec
        { name "y" }
        { offset 4 }
        { type $[ int c-type ] }
        { reader y>> }
        { writer (>>y) }
    }
    T{ field-spec
        { name "z" }
        { offset 8 }
        { type $[ boolean c-type ] }
        { reader z>> }
        { writer (>>z) }
    }
} ] [ "struct-test-foo" c-type fields>> ] unit-test

[ {
    T{ field-spec
        { name "f" }
        { offset 0 }
        { type $[ single-float c-type ] }
        { reader f>> }
        { writer (>>f) }
    }
    T{ field-spec
        { name "bits" }
        { offset 0 }
        { type $[ uint c-type ] }
        { reader bits>> }
        { writer (>>bits) }
    }
} ] [ "struct-test-float-and-bits" c-type fields>> ] unit-test

