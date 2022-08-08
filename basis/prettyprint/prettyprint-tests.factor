USING: accessors arrays classes.intersection classes.maybe
classes.union compiler.units continuations definitions effects
eval generic generic.standard hashtables io io.streams.duplex
io.streams.string kernel listener make math namespaces parser
prettyprint prettyprint.backend prettyprint.config prettyprint.private
prettyprint.sections see sequences splitting
strings system tools.continuations tools.continuations.private
tools.test vectors vocabs.parser words ;
IN: prettyprint.tests

{ "4" } [ 4 unparse ] unit-test
{ "4096" } [ 4096 unparse ] unit-test
{ "0b1000000000000" } [ 2 number-base [ 4096 unparse ] with-variable ] unit-test
{ "0o10000" } [ 8 number-base [ 4096 unparse ] with-variable ] unit-test
{ "0x1000" } [ 16 number-base [ 4096 unparse ] with-variable ] unit-test
{ "1.0" } [ 1.0 unparse ] unit-test
{ "8.0" } [ 8.0 unparse ] unit-test
{ "0b1.001p4" } [ 2 number-base [ 18.0 unparse ] with-variable ] unit-test
{ "0o1.1p4" } [ 8 number-base [ 18.0 unparse ] with-variable ] unit-test
{ "0x1.2p4" } [ 16 number-base [ 18.0 unparse ] with-variable ] unit-test
{ "1267650600228229401496703205376" } [ 1 100 shift unparse ] unit-test
{ "1/0." } [ 1/0. unparse ] unit-test
{ "-1/0." } [ -1/0. unparse ] unit-test
{ "0/0." } [ 0/0. unparse ] unit-test
{ "-0/0." } [ -0/0. unparse ] unit-test

! XXX: disabling on linux/x86.32
os linux? cpu x86.32? and [
    { "NAN: 123" } [ NAN: 123 unparse ] unit-test
] unless
{ "NAN: -123" } [ NAN: -123 unparse ] unit-test

{ "+" } [ \ + unparse ] unit-test

{ "\\ +" } [ [ \ + ] first unparse ] unit-test

{ "{ }" } [ { } unparse ] unit-test

{ "{ 1 2 3 }" } [ { 1 2 3 } unparse ] unit-test

{ "\"hello\\\\backslash\"" }
[ "hello\\backslash" unparse ]
unit-test

! [ "\"\\u123456\"" ]
! [ "\u123456" unparse ]
! unit-test

{ "\"\\e\"" }
[ "\e" unparse ]
unit-test

{ "\"\\x01\"" }
[ 1 1string unparse ]
unit-test

{ "f" } [ f unparse ] unit-test
{ "t" } [ t unparse ] unit-test

{ "SBUF\" hello world\"" } [ SBUF" hello world" unparse ] unit-test

{ "W{ \\ + }" } [ [ W{ \ + } ] first unparse ] unit-test

{ } [ \ fixnum see ] unit-test

{ } [ \ integer see ] unit-test

{ } [ \ generic see ] unit-test

{ } [ \ duplex-stream see ] unit-test

{ "[ \\ + ]" } [ [ \ + ] unparse ] unit-test
{ "[ \\ [ ]" } [ [ \ [ ] unparse ] unit-test

{ t } [
    100 \ dup <array> unparse-short
    "{" head?
] unit-test

: foo ( a -- b ) dup * ; inline

{ "USING: kernel math ;\nIN: prettyprint.tests\n: foo ( a -- b ) dup * ; inline\n" }
[ [ \ foo see ] with-string-writer ] unit-test

: bar ( x -- y ) 2 + ;

{ "USING: math ;\nIN: prettyprint.tests\n: bar ( x -- y ) 2 + ;\n" }
[ [ \ bar see ] with-string-writer ] unit-test

: blah ( a a a a a a a a a a a a a a a a a a a a -- )
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop
    drop ;

{ "drop ;" } [
    [ \ blah see ] with-string-writer "\n" ?tail drop 6 tail*
] unit-test

: check-see ( expect name -- ? )
    [
        [
            [ parse-fresh drop ] with-compilation-unit
            [
                "prettyprint.tests" lookup-word see
            ] with-string-writer split-lines
        ] keep =
    ] with-interactive-vocabs ;

GENERIC: method-layout ( a -- b )

M: complex method-layout
    drop
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    ;

M: fixnum method-layout ;

M: integer method-layout ;

M: object method-layout ;

{
    {
        "USING: kernel math prettyprint.tests ;"
        "M: complex method-layout"
        "    drop"
        "    \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
        "    ;"
        ""
        "USING: math prettyprint.tests ;"
        "M: fixnum method-layout ;"
        ""
        "USING: math prettyprint.tests ;"
        "M: integer method-layout ;"
        ""
        "USING: kernel prettyprint.tests ;"
        "M: object method-layout ;"
    }
} [
    [ \ method-layout see-methods ] with-string-writer split-lines
] unit-test

: soft-break-test ( -- str )
    {
        "USING: kernel math sequences strings ;"
        "IN: prettyprint.tests"
        ": soft-break-layout ( x y -- ? )"
        "    over string? ["
        "        over hashcode over hashcode number="
        "        [ sequence= ] [ 2drop f ] if"
        "    ] [ 2drop f ] if ;"
    } ;

{ t } [
    "soft-break-layout" soft-break-test check-see
] unit-test

DEFER: parse-error-file

: another-soft-break-test ( -- str )
    {
        "USING: make sequences ;"
        "IN: prettyprint.tests"
        ": another-soft-break-layout ( node -- quot )"
        "    parse-error-file"
        "    [ <reversed> \"hello world foo\" suffix ] [ ] make ;"
    } ;

{ t } [
    "another-soft-break-layout" another-soft-break-test
    check-see
] unit-test

: string-layout ( -- str )
    {
        "USING: accessors debugger io kernel ;"
        "IN: prettyprint.tests"
        ": string-layout-test ( error -- )"
        "    \"Expected \" write dup want>> expected>string write"
        "    \" but got \" write got>> expected>string print ;"
    } ;


{ t } [
    "string-layout-test" string-layout check-see
] unit-test

: narrow-test ( -- array )
    {
        "USING: arrays combinators continuations kernel sequences ;"
        "IN: prettyprint.tests"
        ": narrow-layout ( obj1 obj2 -- obj3 )"
        "    {"
        "        { [ dup continuation? ] [ append ] }"
        "        { [ dup not ] [ drop reverse ] }"
        "        { [ dup pair? ] [ [ remove! drop ] keep ] }"
        "    } cond ;"
    } ;

{ t } [
    "narrow-layout" narrow-test check-see
] unit-test

: another-narrow-test ( -- array )
    {
        "IN: prettyprint.tests"
        ": another-narrow-layout ( -- obj )"
        "    H{"
        "        { 1 2 }"
        "        { 3 4 }"
        "        { 5 6 }"
        "        { 7 8 }"
        "        { 9 10 }"
        "        { 11 12 }"
        "        { 13 14 }"
        "    } ;"
    } ;

{ t } [
    "another-narrow-layout" another-narrow-test check-see
] unit-test

IN: prettyprint.tests
TUPLE: class-see-layout ;

IN: prettyprint.tests
GENERIC: class-see-layout ( x -- y )

USING: prettyprint.tests ;
M: class-see-layout class-see-layout ;

{
    {
        "IN: prettyprint.tests"
        "TUPLE: class-see-layout ;"
        ""
        "IN: prettyprint.tests"
        "GENERIC: class-see-layout ( x -- y )"
    }
} [
    [ \ class-see-layout see ] with-string-writer split-lines
] unit-test

{
    {
        "USING: prettyprint.tests ;"
        "M: class-see-layout class-see-layout ;"
    }
} [
    [ \ class-see-layout see-methods ] with-string-writer split-lines
] unit-test

{ } [ \ in>> synopsis drop ] unit-test

! Regression
{ t } [
    "IN: prettyprint.tests\nGENERIC: generic-decl-test ( a -- b ) flushable\n"
    dup eval( -- )
    "generic-decl-test" "prettyprint.tests" lookup-word
    [ see ] with-string-writer =
] unit-test

{ [ + ] } [ [ \ + (step-into-execute) ] (remove-breakpoints) ] unit-test

{ [ (step-into-execute) ] } [ [ (step-into-execute) ] (remove-breakpoints) ] unit-test

{ [ 2 2 + . ] } [
    [ 2 2 \ + (step-into-execute) . ] (remove-breakpoints)
] unit-test

{ [ 2 2 + . ] } [
    [ 2 break 2 \ + (step-into-execute) . ] (remove-breakpoints)
] unit-test

GENERIC: generic-see-test-with-f ( obj -- obj )

M: f generic-see-test-with-f ;

{ "USING: prettyprint.tests ;\nM: f generic-see-test-with-f ;\n" } [
    [ M\ f generic-see-test-with-f see ] with-string-writer
] unit-test

PREDICATE: predicate-see-test < integer even? ;

{ "USING: math ;\nIN: prettyprint.tests\nPREDICATE: predicate-see-test < integer even? ;\n" } [
    [ \ predicate-see-test see ] with-string-writer
] unit-test

INTERSECTION: intersection-see-test sequence number ;

{ "USING: math sequences ;\nIN: prettyprint.tests\nINTERSECTION: intersection-see-test sequence number ;\n" } [
    [ \ intersection-see-test see ] with-string-writer
] unit-test

{ } [ \ compose see ] unit-test
{ } [ \ curry see ] unit-test

{ "POSTPONE: [" } [ \ [ unparse ] unit-test

TUPLE: started-out-hustlin' ;

GENERIC: ended-up-ballin' ( a -- b )

M: started-out-hustlin' ended-up-ballin' ; inline

{ "USING: prettyprint.tests ;\nM: started-out-hustlin' ended-up-ballin' ; inline\n" } [
    [ M\ started-out-hustlin' ended-up-ballin' see ] with-string-writer
] unit-test

TUPLE: tuple-with-declared-slot { x integer } ;

{
    {
        "USING: math ;"
        "IN: prettyprint.tests"
        "TUPLE: tuple-with-declared-slot { x integer initial: 0 } ;"
    }
} [
    [ \ tuple-with-declared-slot see ] with-string-writer split-lines
] unit-test

TUPLE: tuple-with-read-only-slot { x read-only } ;

{
    {
        "IN: prettyprint.tests"
        "TUPLE: tuple-with-read-only-slot { x read-only } ;"
    }
} [
    [ \ tuple-with-read-only-slot see ] with-string-writer split-lines
] unit-test

TUPLE: tuple-with-initial-slot { x initial: 123 } ;

{
    {
        "IN: prettyprint.tests"
        "TUPLE: tuple-with-initial-slot { x initial: 123 } ;"
    }
} [
    [ \ tuple-with-initial-slot see ] with-string-writer split-lines
] unit-test

TUPLE: tuple-with-initial-declared-slot { x integer initial: 123 } ;

{
    {
        "USING: math ;"
        "IN: prettyprint.tests"
        "TUPLE: tuple-with-initial-declared-slot"
        "    { x integer initial: 123 } ;"
    }
} [
    [ \ tuple-with-initial-declared-slot see ] with-string-writer split-lines
] unit-test

TUPLE: final-tuple ; final

{
    {
        "IN: prettyprint.tests"
        "TUPLE: final-tuple ; final"
    }
} [
    [ \ final-tuple see ] with-string-writer split-lines
] unit-test

{ "H{ { 1 2 } }\n" } [ [ H{ { 1 2 } } short. ] with-string-writer ] unit-test

{ "H{ { 1 ~array~ } }\n" } [ [ H{ { 1 { 2 } } } short. ] with-string-writer ] unit-test

{ "{ ~array~ }\n" } [ [ { { 1 2 } } short. ] with-string-writer ] unit-test

{ "{ { 1 2 } }\n" } [ [ [ { { 1 2 } } short. ] without-limits ] with-string-writer ] unit-test

{ "{ ~array~ }\n" } [ [ [ { { 1 2 } } . ] with-short-limits ] with-string-writer ] unit-test

{ "H{ { 1 { 2 3 } } }\n" } [
    f nesting-limit [
        [ H{ { 1 { 2 3 } } } . ] with-string-writer
    ] with-variable
] unit-test

{ "maybe{ integer }\n" } [ [  maybe{ integer } . ] with-string-writer ] unit-test
TUPLE: bob a b ;
{ "maybe{ bob }\n" } [ [ maybe{ bob } . ] with-string-writer ] unit-test
{ "maybe{ word }\n" } [ [ maybe{ word } . ] with-string-writer ] unit-test

TUPLE: har a ;
GENERIC: harhar ( obj -- obj )
M: maybe{ har } harhar ;
M: integer harhar M\ integer harhar drop ;
{
"USING: prettyprint.tests ;
M: maybe{ har } harhar ;

USING: kernel math prettyprint.tests ;
M: integer harhar M\\ integer harhar drop ;\n"
} [
    [ \ harhar see-methods ] with-string-writer
] unit-test

TUPLE: mo { a union{ float integer } } ;
TUPLE: fo { a intersection{ fixnum integer } } ;

{
"USING: math ;
IN: prettyprint.tests
TUPLE: mo { a union{ integer float } initial: 0 } ;
"
} [
    [ \ mo see ] with-string-writer
] unit-test

{
"USING: math ;
IN: prettyprint.tests
TUPLE: fo { a intersection{ integer fixnum } initial: 0 } ;
"
} [
    [ \ fo see ] with-string-writer
] unit-test

{
"union{ intersection{ string hashtable } union{ integer float } }\n"
} [ [ union{ union{ float integer } intersection{ string hashtable } } . ] with-string-writer ] unit-test

{
"intersection{
    intersection{ string hashtable }
    union{ integer float }
}
"
} [ [ intersection{ union{ float integer } intersection{ string hashtable } } . ] with-string-writer ] unit-test

{
"maybe{ union{ integer float } }\n"
} [
    [ maybe{ union{ float integer } } . ] with-string-writer
] unit-test

{
"maybe{ maybe{ integer } }\n"
} [
    [ maybe{ maybe{ integer } } . ] with-string-writer
] unit-test

{ "{ 0 1 2 3 4 }" } [
    [ 5 length-limit [ 5 <iota> >array pprint ] with-variable ]
    with-string-writer
] unit-test

{ "{ 0 1 2 3 ~2 more~ }" } [
    [ 5 length-limit [ 6 <iota> >array pprint ] with-variable ]
    with-string-writer
] unit-test

: margin-test ( number-of-'a's -- str )
    [
        [ CHAR: a <string> text "b" text ] with-pprint
    ] with-string-writer ;

{
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa b"
} [ margin get 3 - margin-test ] unit-test

{
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa b"
} [ margin get 2 - margin-test ] unit-test

{
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
b"
} [ margin get 1 - margin-test ] unit-test
