IN: temporary
USING: alien alien.syntax alien.c-types kernel tools.test
sequences system libc words vocabs namespaces ;

C-STRUCT: bar
    { "int" "x" }
    { { "int" 8 } "y" } ;

[ 36 ] [ "bar" heap-size ] unit-test
[ t ] [ \ <displaced-alien> "bar" c-type c-type-getter memq? ] unit-test

C-STRUCT: align-test
    { "int" "x" }
    { "double" "y" } ;

[ 16 ] [ "align-test" heap-size ] unit-test

cell 4 = [
    C-STRUCT: one
    { "long" "a" } { "double" "b" } { "int" "c" } ;

    [ 24 ] [ "one" heap-size ] unit-test
] when

: MAX_FOOS 30 ;

C-STRUCT: foox
    { { "int" MAX_FOOS } "x" } ;

[ 120 ] [ "foox" heap-size ] unit-test

C-UNION: barx
    { "int" MAX_FOOS }
    "float" ;

[ 120 ] [ "barx" heap-size ] unit-test

"help" vocab [
    "help" "help" lookup "help" set
    [ ] [ \ foox-x "help" get execute ] unit-test
    [ ] [ \ set-foox-x "help" get execute ] unit-test
] when
