USING: arrays definitions io.streams.string io.streams.duplex
kernel math namespaces parser prettyprint prettyprint.config
prettyprint.sections sequences tools.test vectors words
effects splitting generic.standard prettyprint.private
continuations generic compiler.units tools.continuations
tools.continuations.private eval accessors make vocabs.parser see ;
IN: prettyprint.tests

[ "4" ] [ 4 unparse ] unit-test
[ "1.0" ] [ 1.0 unparse ] unit-test
[ "1267650600228229401496703205376" ] [ 1 100 shift unparse ] unit-test

[ "+" ] [ \ + unparse ] unit-test

[ "\\ +" ] [ [ \ + ] first unparse ] unit-test

[ "{ }" ] [ { } unparse ] unit-test

[ "{ 1 2 3 }" ] [ { 1 2 3 } unparse ] unit-test

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" unparse ]
unit-test

! [ "\"\\u123456\"" ]
! [ "\u123456" unparse ]
! unit-test

[ "\"\\e\"" ]
[ "\e" unparse ]
unit-test

[ "f" ] [ f unparse ] unit-test
[ "t" ] [ t unparse ] unit-test

[ "SBUF\" hello world\"" ] [ SBUF" hello world" unparse ] unit-test

[ "W{ \\ + }" ] [ [ W{ \ + } ] first unparse ] unit-test

[ ] [ \ fixnum see ] unit-test

[ ] [ \ integer see ] unit-test

[ ] [ \ generic see ] unit-test

[ ] [ \ duplex-stream see ] unit-test

[ "[ \\ + ]" ] [ [ \ + ] unparse ] unit-test
[ "[ \\ [ ]" ] [ [ \ [ ] unparse ] unit-test
    
[ t ] [
    100 \ dup <array> unparse-short
    "{" head?
] unit-test

: foo ( a -- b ) dup * ; inline

[ "USING: kernel math ;\nIN: prettyprint.tests\n: foo ( a -- b ) dup * ; inline\n" ]
[ [ \ foo see ] with-string-writer ] unit-test

: bar ( x -- y ) 2 + ;

[ "USING: math ;\nIN: prettyprint.tests\n: bar ( x -- y ) 2 + ;\n" ]
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

[ "drop ;" ] [
    \ blah f "inferred-effect" set-word-prop
    [ \ blah see ] with-string-writer "\n" ?tail drop 6 tail*
] unit-test

: check-see ( expect name -- ? )
    [
        use [ clone ] change

        [
            [ parse-fresh drop ] with-compilation-unit
            [
                "prettyprint.tests" lookup see
            ] with-string-writer "\n" split but-last
        ] keep =
    ] with-scope ;

GENERIC: method-layout ( a -- b )

M: complex method-layout
    drop
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    ;

M: fixnum method-layout ;

M: integer method-layout ;

M: object method-layout ;

[
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
        ""
    }
] [
    [ \ method-layout see-methods ] with-string-writer "\n" split
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

[ t ] [
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

[ t ] [
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


[ t ] [
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
        "        { [ dup pair? ] [ [ delete ] keep ] }"
        "    } cond ;"
    } ;

[ t ] [
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

[ t ] [
    "another-narrow-layout" another-narrow-test check-see
] unit-test

IN: prettyprint.tests
TUPLE: class-see-layout ;

IN: prettyprint.tests
GENERIC: class-see-layout ( x -- y )

USING: prettyprint.tests ;
M: class-see-layout class-see-layout ;

[
    {
        "IN: prettyprint.tests"
        "TUPLE: class-see-layout ;"
        ""
        "IN: prettyprint.tests"
        "GENERIC: class-see-layout ( x -- y )"
        ""
    }
] [
    [ \ class-see-layout see ] with-string-writer "\n" split
] unit-test

[
    {
        "USING: prettyprint.tests ;"
        "M: class-see-layout class-see-layout ;"
        ""
    }
] [
    [ \ class-see-layout see-methods ] with-string-writer "\n" split
] unit-test

[ ] [ \ in>> synopsis drop ] unit-test

! Regression
[ t ] [
    "IN: prettyprint.tests\nGENERIC: generic-decl-test ( a -- b ) flushable\n"
    dup eval( -- )
    "generic-decl-test" "prettyprint.tests" lookup
    [ see ] with-string-writer =
] unit-test

[ [ + ] ] [ [ \ + (step-into-execute) ] (remove-breakpoints) ] unit-test

[ [ (step-into-execute) ] ] [ [ (step-into-execute) ] (remove-breakpoints) ] unit-test
 
[ [ 2 2 + . ] ] [
    [ 2 2 \ + (step-into-execute) . ] (remove-breakpoints)
] unit-test

[ [ 2 2 + . ] ] [
    [ 2 break 2 \ + (step-into-execute) . ] (remove-breakpoints)
] unit-test

GENERIC: generic-see-test-with-f ( obj -- obj )

M: f generic-see-test-with-f ;

[ "USING: prettyprint.tests ;\nM: f generic-see-test-with-f ;\n" ] [
    [ M\ f generic-see-test-with-f see ] with-string-writer
] unit-test

PREDICATE: predicate-see-test < integer even? ;

[ "USING: math ;\nIN: prettyprint.tests\nPREDICATE: predicate-see-test < integer even? ;\n" ] [
    [ \ predicate-see-test see ] with-string-writer
] unit-test

INTERSECTION: intersection-see-test sequence number ;

[ "USING: math sequences ;\nIN: prettyprint.tests\nINTERSECTION: intersection-see-test sequence number ;\n" ] [
    [ \ intersection-see-test see ] with-string-writer
] unit-test

[ ] [ \ compose see ] unit-test
[ ] [ \ curry see ] unit-test

[ "POSTPONE: [" ] [ \ [ unparse ] unit-test
    
TUPLE: started-out-hustlin' ;

GENERIC: ended-up-ballin' ( a -- b )

M: started-out-hustlin' ended-up-ballin' ; inline

[ "USING: prettyprint.tests ;\nM: started-out-hustlin' ended-up-ballin' ; inline\n" ] [
    [ M\ started-out-hustlin' ended-up-ballin' see ] with-string-writer
] unit-test
