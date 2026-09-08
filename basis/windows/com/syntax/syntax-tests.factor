USING: alien.c-types io.streams.string kernel parser sequences
tools.test vocabs words ;
IN: windows.com.syntax.tests

! The interface typedef must belong to the source file, just like
! its generated IID and method words (issue #1976).
{ t t t } [
    "USING: alien.c-types windows.com.syntax ; IN: windows.com.syntax.reload-test COM-INTERFACE: IFoo f {00000000-0000-0000-0000-000000000000} int Value ( ) ;"
    <string-reader> "com-interface-reload-test" parse-stream drop
    "IFoo" "windows.com.syntax.reload-test" lookup-word c-type-word?
    { "IFoo-iid" "IFoo::Value" }
    [ "windows.com.syntax.reload-test" lookup-word >boolean ] each
] unit-test

{ f f f t t t } [
    "USING: alien.c-types windows.com.syntax ; IN: windows.com.syntax.reload-test COM-INTERFACE: IBar f {00000000-0000-0000-0000-000000000000} int Value ( ) ;"
    <string-reader> "com-interface-reload-test" parse-stream drop
    { "IFoo" "IFoo-iid" "IFoo::Value" }
    [ "windows.com.syntax.reload-test" lookup-word >boolean ] each
    "IBar" "windows.com.syntax.reload-test" lookup-word c-type-word?
    { "IBar-iid" "IBar::Value" }
    [ "windows.com.syntax.reload-test" lookup-word >boolean ] each
] unit-test

{ f f f } [
    "IN: windows.com.syntax.reload-test"
    <string-reader> "com-interface-reload-test" parse-stream drop
    { "IBar" "IBar-iid" "IBar::Value" }
    [ "windows.com.syntax.reload-test" lookup-word >boolean ] each
] unit-test
