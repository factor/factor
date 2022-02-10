USING: documents documents.private accessors sequences
namespaces tools.test make arrays kernel fry ;

! Tests

{ { } } [
    [
        { 1 10 }
        { 1 10 } [ , "HI" , ] each-doc-line
    ] { } make
] unit-test

{ { 1 "HI" } } [
    [
        { 1 10 }
        { 1 11 } [ , "HI" , ] each-doc-line
    ] { } make
] unit-test

{ { 1 "HI" 2 "HI" } } [
    [
        { 1 10 }
        { 2 11 } [ , "HI" , ] each-doc-line
    ] { } make
] unit-test

{ { { t f 1 } { t f 2 } } } [
    [
        { 1 10 } { 2 11 }
        t f
        '[ [ _ _ ] dip 3array , ] each-doc-line
    ] { } make
] unit-test

{ { 10 4 } } [ { "a" } { 10 3 } text+loc ] unit-test
{ { 10 4 } } [ { "a" } { 10 3 } text+loc ] unit-test

{ { 2 9 } } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    { 10 0 } "doc" get validate-loc
] unit-test

{ { 1 12 } } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    { 1 20 } "doc" get validate-loc
] unit-test

{ " world,\nhow are you?\nMore" } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    { 0 5 } { 2 4 } "doc" get doc-range
] unit-test

{ "Hello world,\nhow you?\nMore text" } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    { 1 3 } { 1 7 } "doc" get remove-doc-range
    "doc" get doc-string
] unit-test

{ "Hello world,\nhow text" } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    { 1 3 } { 2 4 } "doc" get remove-doc-range
    "doc" get doc-string
] unit-test

{ "Hello world,\nhow you?\nMore text" } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    "" { 1 3 } { 1 7 } "doc" get set-doc-range
    "doc" get doc-string
] unit-test

{ "Hello world,\nhow text" } [
    <document> "doc" set
    "Hello world,\nhow are you?\nMore text"
    "doc" get set-doc-string
    "" { 1 3 } { 2 4 } "doc" get set-doc-range
    "doc" get doc-string
] unit-test

<document> "doc" set
"Hello\nworld, how are\nyou?" "doc" get set-doc-string

{ { 2 4 } } [ "doc" get doc-end ] unit-test

! Undo/redo
{ } [ <document> "d" set ] unit-test

{ } [ "Hello, world." "d" get set-doc-string ] unit-test

{
    T{ edit
       { old-string "" }
       { new-string "Hello, world." }
       { from { 0 0 } }
       { old-to { 0 0 } }
       { new-to { 0 13 } }
    }
} [ "d" get undos>> first ] unit-test

{ } [ "Goodbye" { 0 0 } { 0 5 } "d" get set-doc-range ] unit-test

{ "Goodbye, world." } [ "d" get doc-string ] unit-test

{ } [ "cruel " { 0 9 } { 0 9 } "d" get set-doc-range ] unit-test

{ 3 } [ "d" get undos>> length ] unit-test

{ "Goodbye, cruel world." } [ "d" get doc-string ] unit-test

{ "" { 0 9 } { 0 15 } } [
    "d" get undos>> last
    [ old-string>> ] [ from>> ] [ new-to>> ] tri
] unit-test

{ } [ "d" get undo ] unit-test

{ "Goodbye, world." } [ "d" get doc-string ] unit-test

{ } [ "d" get undo ] unit-test

{ "Hello, world." } [ "d" get doc-string ] unit-test

{ } [ "d" get redo ] unit-test

{ "Goodbye, world." } [ "d" get doc-string ] unit-test

{ } [ <document> "d" set ] unit-test

{ } [ "d" get clear-doc ] unit-test

{ } [ "d" get clear-doc ] unit-test

{ 0 } [ "d" get undos>> length ] unit-test

{ } [ <document> "d" set ] unit-test

{ } [ "d" get value>> "value" set ] unit-test

{ } [ "Hello world" "d" get set-doc-string ] unit-test

{ { "" } } [ "value" get ] unit-test
