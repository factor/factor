USING: accessors definitions help help.topics help.crossref
help.markup help.syntax kernel sequences tools.test words parser
namespaces assocs source-files eval ;
IN: help.topics.tests

! Test help cross-referencing

[ ] [ "Test B" { "Hello world." } <article> { "test" "b" } add-article ] unit-test

[ ] [ "Test A" { { $subsection { "test" "b" } } } <article> { "test" "a" } add-article ] unit-test

SYMBOL: foo

[ ] [ "Test A" { { $subsection foo } } <article> { "test" "a" } add-article ] unit-test

! Test article location recording

[ ] [
    {
        "USE: help.syntax"
        "ARTICLE: { \"test\" 1 } \"Hello\""
        "\"abc\""
        "\"def\" ;"
    } "\n" join
    [
        "testfile" source-file file set
        eval( -- )
    ] with-scope
] unit-test

[ { "testfile" 2 } ]
[ { "test" 1 } articles get at loc>> ] unit-test

[ ] [ { "test" 1 } remove-article ] unit-test
