IN: temporary
USING: xmode.utilities tools.test xml xml.data
kernel strings vectors sequences io.files prettyprint assocs ;

[ 3 "hi" ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 3 "hi" } } at ] map-find
] unit-test

[ f f ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 11 "hi" } } at ] map-find
] unit-test

TUPLE: company employees type ;

: <company> V{ } clone f company construct-boa ;

: add-employee company-employees push ;

<TAGS: parse-employee-tag

TUPLE: employee name description ;

TAG: employee
    employee construct-empty
    { { "name" f set-employee-name } { f set-employee-description } }
    init-from-tag swap add-employee ;

TAGS>

\ parse-employee-tag see

: parse-company-tag
    [
        <company>
        { { "type" >upper set-company-type } }
        init-from-tag dup
    ] keep
    tag-children [ tag? ] subset
    [ parse-employee-tag ] curry* each ;

[
    T{ company f
        V{
            T{ employee f "Joe" "VP Sales" }
            T{ employee f "Jane" "CFO" }
        }
        "PUBLIC"
        "This is a great company"
    }
] [
    "extra/xmode/utilities/test.xml"
    resource-path <file-reader> read-xml parse-company-tag
] unit-test
