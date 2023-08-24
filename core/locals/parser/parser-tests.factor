USING: accessors assocs compiler.units kernel lexer
locals.backend locals.parser parser prettyprint sequences
tools.test vocabs.parser ;
IN: locals.parser.tests

! (::)
<<
{
    "dobiedoo"
    [ load-local 1 drop-locals ]
    ( x -- y )
} [
    [
        { "dobiedoo ( x -- y ) ;" } <lexer> [ (::) ] with-lexer
    ] with-compilation-unit
    [ name>> ] 2dip
] unit-test

{
    "dobiedoo"
    [ 2 load-locals 2 drop-locals ]
    ( x y -- z )
} [
    [
        { "dobiedoo ( x y -- z ) ;" } <lexer> [ (::) ] with-lexer
    ] with-compilation-unit
    [ name>> ] 2dip
] unit-test

! parse-def
{ "um" t } [
    [
        "um" parse-def
        locals>> first name>>
        qualified-vocabs last words>> keys "um" swap member?
    ] with-compilation-unit
] unit-test
>>

! check-local-name
{ "hello" } [
    "hello" check-local-name
] unit-test

! make-locals
{ { "a" "b" "c" } } [
    [ { "a" "b" "c" } make-locals ] with-compilation-unit
    nip values [ name>> ] map
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
    { "tok1" "tok2" }
    { "tok1" "tok2" }
} [
    [
        { "tok1 tok2 )" } <lexer> [ parse-multi-def ] with-lexer
    ] with-compilation-unit
    [ locals>> [ name>> ] map ] [ keys ] bi*
] unit-test

<<
{
    "V{ 99 :> kkk kkk }"
} [
    [
        { "99 :> kkk kkk ;" } <lexer> [
            H{ } clone [ \ ; parse-until ] with-lambda-scope
        ] with-lexer
    ] with-compilation-unit unparse
] unit-test
>>
