IN: temporary
USING: gadgets-text namespaces test ;

! Tests

[ { 10 4 } ] [ { "a" } { 10 3 } text+loc ] unit-test
[ { 10 4 } ] [ { "a" } { 10 3 } text+loc ] unit-test

[ { 2 0 } ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    { 10 0 } "doc" get validate-loc
] unit-test

[ { 1 12 } ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    { 1 20 } "doc" get validate-loc
] unit-test

[ " world,\nhow are you?\nMore" ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    { 0 5 } { 2 4 } "doc" get doc-range
] unit-test

[ "Hello world,\nhow you?\nMore text" ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    { 1 3 } { 1 7 } "doc" get remove-doc-range
    "doc" get doc-text
] unit-test

[ "Hello world,\nhow text" ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    { 1 3 } { 2 4 } "doc" get remove-doc-range
    "doc" get doc-text
] unit-test

[ "Hello world,\nhow you?\nMore text" ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    "" { 1 3 } { 1 7 } "doc" get set-doc-range
    "doc" get doc-text
] unit-test

[ "Hello world,\nhow text" ] [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-text
    "" { 1 3 } { 2 4 } "doc" get set-doc-range
    "doc" get doc-text
] unit-test

<document> "doc" set
"Hello world" "doc" get set-doc-text
[ { 0 0 } ] [ { 0 0 } "doc" get T{ one-word-elt } prev-elt ] unit-test
[ { 0 0 } ] [ { 0 2 } "doc" get T{ one-word-elt } prev-elt ] unit-test
[ { 0 0 } ] [ { 0 5 } "doc" get T{ one-word-elt } prev-elt ] unit-test
[ { 0 5 } ] [ { 0 2 } "doc" get T{ one-word-elt } next-elt ] unit-test
[ { 0 5 } ] [ { 0 5 } "doc" get T{ one-word-elt } next-elt ] unit-test
