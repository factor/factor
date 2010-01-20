USING: eval tools.test compiler.units vocabs words kernel
definitions sequences ;
IN: compiler.tests.redefine10

! Mixin redefinition should update predicate call sites

[ ] [
    "USING: kernel math classes ;
    IN: compiler.tests.redefine10
    MIXIN: my-mixin
    INSTANCE: fixnum my-mixin
    : my-inline-1 ( a -- b ) dup my-mixin instance? [ 1 + ] when ;
    : my-inline-2 ( a -- b ) dup my-mixin? [ 1 + ] when ;
    : my-inline-3 ( a -- b ) dup my-mixin? [ float? ] [ drop f ] if ;
    : my-inline-4 ( a -- b ) dup float? [ my-mixin? ] [ drop f ] if ;
    : my-inline-5 ( a -- b ) dup my-mixin? [ fixnum? ] [ drop f ] if ;
    : my-inline-6 ( a -- b ) dup fixnum? [ my-mixin? ] [ drop f ] if ;"
    eval( -- )
] unit-test

[ f ] [
    5 "my-inline-3" "compiler.tests.redefine10" lookup execute
] unit-test

[ f ] [
    5 "my-inline-4" "compiler.tests.redefine10" lookup execute
] unit-test

[ t ] [
    5 "my-inline-5" "compiler.tests.redefine10" lookup execute
] unit-test

[ t ] [
    5 "my-inline-6" "compiler.tests.redefine10" lookup execute
] unit-test

[ ] [
    "USE: math
    IN: compiler.tests.redefine10
    INSTANCE: float my-mixin"
    eval( -- )
] unit-test

[ 2.0 ] [
    1.0 "my-inline-1" "compiler.tests.redefine10" lookup execute
] unit-test

[ 2.0 ] [
    1.0 "my-inline-2" "compiler.tests.redefine10" lookup execute
] unit-test

[ t ] [
    1.0 "my-inline-3" "compiler.tests.redefine10" lookup execute
] unit-test

[ t ] [
    1.0 "my-inline-4" "compiler.tests.redefine10" lookup execute
] unit-test

[ f ] [
    1.0 "my-inline-5" "compiler.tests.redefine10" lookup execute
] unit-test

[ f ] [
    1.0 "my-inline-6" "compiler.tests.redefine10" lookup execute
] unit-test

[
    {
        "my-mixin" "my-inline-1" "my-inline-2"
    } [ "compiler.tests.redefine10" lookup forget ] each
] with-compilation-unit
