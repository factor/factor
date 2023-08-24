USING: io.crlf tools.test io.streams.string io ;

{ "Hello, world." } [ "Hello, world." [ read-crlf ] with-string-reader ] unit-test
{ "Hello, world." } [ "Hello, world.\r\n" [ read-crlf ] with-string-reader ] unit-test
[ "Hello, world.\r" [ read-crlf ] with-string-reader ] must-fail
{ f } [ "" [ read-crlf ] with-string-reader ] unit-test
{ "" } [ "\r\n" [ read-crlf ] with-string-reader ] unit-test

[ "foo\r" [ read-?crlf ] with-string-reader ] must-fail
{ f } [ "" [ read-?crlf ] with-string-reader ] unit-test
{ "" } [ "\n" [ read-?crlf ] with-string-reader ] unit-test
{ "foo" } [ "foo\n" [ read-?crlf ] with-string-reader ] unit-test

{ "foo\nbar" } [ "foo\n\rbar" crlf>lf ] unit-test
{ "foo\r\nbar" } [ "foo\nbar" lf>crlf ] unit-test

{ f } [ "" [ read1-ignoring-crlf ] with-string-reader ] unit-test
{ CHAR: a } [ "a" [ read1-ignoring-crlf ] with-string-reader ] unit-test
{ CHAR: b } [ "\nb" [ read1-ignoring-crlf ] with-string-reader ] unit-test
{ CHAR: c } [ "\r\nc" [ read1-ignoring-crlf ] with-string-reader ] unit-test

{ f } [ "" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "a" } [ "a" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "ab" } [ "a\nb" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "abc" } [ "a\nb\r\nc" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "abcd" } [ "a\nb\r\ncd" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "abcde" } [ "a\nb\r\ncd\r\ne" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test
{ "abcde" } [ "a\nb\r\ncd\r\ne\nfghi" [ 5 read-ignoring-crlf ] with-string-reader ] unit-test

{ "Hello\r\nworld.\r\n" } [
    [ use-crlf-stream "Hello" print "world." write nl ] with-string-writer
] unit-test

{ "A\nB\r\nC\n" } [
    [
        "A" print
        [ "B" print ] with-crlf-stream
        "C" print
    ] with-string-writer
] unit-test
