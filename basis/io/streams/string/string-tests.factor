USING: io.streams.string io kernel arrays namespaces make
tools.test ;

{ "" } [ "" [ read-contents ] with-string-reader ] unit-test

{ "line 1" CHAR: l }
[
    "line 1\nline 2\nline 3" [ readln read1 ] with-string-reader
]
unit-test

{ { "line 1" "line 2" "line 3" } } [
    "line 1\nline 2\nline 3" [ read-lines ] with-string-reader
] unit-test

{ { "" "foo" "bar" "baz" } } [
    "\rfoo\r\nbar\rbaz\n" [ read-lines ] with-string-reader
] unit-test

{ f } [ "" [ readln ] with-string-reader ] unit-test

{ "xyzzy" } [ [ "xyzzy" write ] with-string-writer ] unit-test

{ "a" } [ "abc" [ 1 read ] with-string-reader ] unit-test
{ "ab" } [ "abc" [ 2 read ] with-string-reader ] unit-test
{ "abc" } [ "abc" [ 3 read ] with-string-reader ] unit-test
{ "abc" } [ "abc" [ 4 read ] with-string-reader ] unit-test
{ "abc" f } [ "abc" [ 3 read read1 ] with-string-reader ] unit-test

{
    { "It seems " CHAR: J }
    { "obs has lost h" CHAR: i }
    { "s grasp on reality again.\n" f }
} [
    "It seems Jobs has lost his grasp on reality again.\n" [
        "J" read-until 2array
        "i" read-until 2array
        "X" read-until 2array
    ] with-string-reader
] unit-test

{ "" CHAR: \r } [ "\r\n" [ "\r" read-until ] with-string-reader ] unit-test
{ f f } [ "" [ "\r" read-until ] with-string-reader ] unit-test

{ "hello" "hi" } [
    "hello\nhi" [ readln 2 read ] with-string-reader
] unit-test

{ "hello" "hi" } [
    "hello\r\nhi" [ readln 2 read ] with-string-reader
] unit-test

{ "hello" "hi" } [
    "hello\rhi" [ readln 2 read ] with-string-reader
] unit-test

! Issue #70 github
{ f } [ "" [ 0 read ] with-string-reader ] unit-test
{ f } [ "" [ 1 read ] with-string-reader ] unit-test
{ f } [ "" [ readln ] with-string-reader ] unit-test
{ "\"\"" } [ "\"\"" [ readln ] with-string-reader ] unit-test
