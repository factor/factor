USING: accessors assocs compiler.units kernel lexer locals.backend
locals.parser parser prettyprint sequences tools.test ;
IN: locals.parser.tests

SYMBOL: dobiedoo

! (::)
{
    dobiedoo
    [ 1 load-locals 1 drop-locals ]
    ( x -- y )
} [
    [
        { "dobiedoo ( x -- y ) ;" } <lexer> [ (::) ] with-lexer
    ] with-compilation-unit
] unit-test

! ((parse-lambda))
{
    "V{ 99 :> kkk kkk }"
} [
    [ { "99 :> kkk kkk ;" } <lexer> [
        H{ } clone [ \ ; parse-until ] ((parse-lambda)) ] with-lexer
    ] with-compilation-unit unparse
] unit-test

! check-local-name
{ "hello" } [
    "hello" check-local-name
] unit-test

! make-locals
{ { "a" "b" "c" } } [
    [ { "a" "b" "c" } make-locals ] with-compilation-unit
    nip values [ name>> ] map
] unit-test

! parse-def
{ "um" { "um" } } [
    [ "um" H{ } clone [ parse-def ] keep ] with-compilation-unit
    [ local>> name>> ] [ keys ] bi*
] unit-test

! parse-local-defs
{ { "tok1" "tok2" } } [
    [
        { "tok1 tok2 |" } <lexer> [ parse-local-defs ] with-lexer
    ] with-compilation-unit
    nip values [ name>> ] map
] unit-test

! parse-multi-def
{
    { "v1" "tok1" "tok2" }
    { "tok1" "tok2" }
} [
    [
        { "tok1 tok2 )" } <lexer> [
            H{ { "v1" t } } clone dup parse-multi-def
        ] with-lexer
    ] with-compilation-unit
    [ keys ] [ locals>> [ name>> ] map ] bi*
] unit-test
