IN: alien.structs.tests
USING: alien alien.syntax alien.c-types kernel tools.test
sequences system libc words vocabs namespaces layouts ;

C-STRUCT: bar
    { "int" "x" }
    { { "int" 8 } "y" } ;

[ 36 ] [ "bar" heap-size ] unit-test
[ t ] [ \ <displaced-alien> "bar" c-type-getter memq? ] unit-test

C-STRUCT: align-test
    { "int" "x" }
    { "double" "y" } ;

os winnt? cpu x86? and [
    [ 16 ] [ "align-test" heap-size ] unit-test
    
    cell 4 = [
        C-STRUCT: one
        { "long" "a" } { "double" "b" } { "int" "c" } ;
    
        [ 24 ] [ "one" heap-size ] unit-test
    ] when
] when

CONSTANT: MAX_FOOS 30

C-STRUCT: foox
    { { "int" MAX_FOOS } "x" } ;

[ 120 ] [ "foox" heap-size ] unit-test

C-UNION: barx
    { "int" MAX_FOOS }
    "float" ;

[ 120 ] [ "barx" heap-size ] unit-test

"help" vocab [
    "print-topic" "help" lookup "help" set
    [ ] [ \ foox-x "help" get execute ] unit-test
    [ ] [ \ set-foox-x "help" get execute ] unit-test
] when

C-STRUCT: nested
    { "int" "x" } ;

C-STRUCT: nested-2
    { "nested" "y" } ;

[ 4 ] [
    "nested-2" <c-object>
    "nested" <c-object>
    4 over set-nested-x
    over set-nested-2-y
    nested-2-y
    nested-x
] unit-test
