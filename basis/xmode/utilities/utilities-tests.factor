IN: xmode.utilities.tests
USING: accessors xmode.utilities tools.test xml xml.data kernel
strings vectors sequences io.files prettyprint assocs
unicode.case ;
[ "hi" 3 ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 3 "hi" } } at ] map-find
] unit-test

[ f f ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 11 "hi" } } at ] map-find
] unit-test

TUPLE: company employees type ;

: <company> V{ } clone f company boa ;

: add-employee employees>> push ;

<TAGS: parse-employee-tag

TUPLE: employee name description ;

TAG: employee
    employee new
    { { "name" f (>>name) } { f (>>description) } }
    init-from-tag swap add-employee ;

TAGS>

\ parse-employee-tag see

: parse-company-tag
    [
        <company>
        { { "type" >upper (>>type) } }
        init-from-tag dup
    ] keep
    children>> [ tag? ] filter
    [ parse-employee-tag ] with each ;

[
    T{ company f
        V{
            T{ employee f "Joe" "VP Sales" }
            T{ employee f "Jane" "CFO" }
        }
        "PUBLIC"
    }
] [
    "vocab:xmode/utilities/test.xml"
    file>xml parse-company-tag
] unit-test
