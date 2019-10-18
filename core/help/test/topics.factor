IN: temporary
USING: definitions help kernel sequences test words parser
namespaces assocs ;

! Test help cross-referencing

"Test B" { "Hello world." } f <article> { "test" "b" } add-article

"Test A" { { $subsection { "test" "b" } } } f <article> { "test" "a" } add-article

{ "test" "a" } remove-article

[ f ] [ { "test" "b" } parent ] unit-test

SYMBOL: foo

{ "test" "a" } "Test A" { { $subsection foo } } f <article> add-article

! Test article location recording

[ ] [
    {
        "ARTICLE: { \"test\" 1 } \"Hello\""
        "\"abc\""
        "\"def\" ;"
    } "\n" join
    [
        "testfile" file set
        eval
    ] with-scope
] unit-test

[ { "testfile" 1 } ]
[ { "test" 1 } articles get at article-loc ] unit-test

[ ] [ { "test" 1 } remove-article ] unit-test
