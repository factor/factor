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
