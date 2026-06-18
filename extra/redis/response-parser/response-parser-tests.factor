! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel redis.response-parser sequences
tools.test ;
IN: redis.response-parser.tests

: read-resp ( resp-string -- response )
    utf8 encode binary [ read-response ] with-byte-reader ;

! RESP2
{ 1 } [ ":1\r\n" read-resp ] unit-test

{ "hello" } [ "$5\r\nhello\r\n" read-resp ] unit-test

! bulk length is the UTF-8 byte count, decoded back to text
{ "héllo" } [ "$6\r\nhéllo\r\n" read-resp ] unit-test

{ f } [ "$-1\r\n" read-resp ] unit-test

{ { "hello" "world!" } } [
    "*2\r\n$5\r\nhello\r\n$6\r\nworld!\r\n" read-resp
] unit-test

{ { "hello" f "world!" } } [
    "*3\r\n$5\r\nhello\r\n$-1\r\n$6\r\nworld!\r\n" read-resp
] unit-test

{ f } [ "*-1\r\n" read-resp ] unit-test

[ "-ERR no such key\r\n" read-resp ] [ redis-error? ] must-fail-with

! RESP3
{ f } [ "_\r\n" read-resp ] unit-test

{ t } [ "#t\r\n" read-resp ] unit-test

{ f } [ "#f\r\n" read-resp ] unit-test

{ 3.14 } [ ",3.14\r\n" read-resp ] unit-test

! integer-valued double comes back as a float
{ 5.0 } [ ",5\r\n" read-resp ] unit-test

{ 1/0. } [ ",inf\r\n" read-resp ] unit-test

{ 12345678901234567890 } [ "(12345678901234567890\r\n" read-resp ] unit-test

{ "Some string" } [ "=15\r\ntxt:Some string\r\n" read-resp ] unit-test

! map -> alist of key/value pairs
{ { { "key" "value" } } } [
    "%1\r\n$3\r\nkey\r\n$5\r\nvalue\r\n" read-resp
] unit-test

! set -> array
{ { "a" "b" } } [ "~2\r\n$1\r\na\r\n$1\r\nb\r\n" read-resp ] unit-test

! attribute reply is skipped, real reply returned
{ 5 } [ "|1\r\n$3\r\nkey\r\n$3\r\nval\r\n:5\r\n" read-resp ] unit-test

[ "!21\r\nSYNTAX invalid syntax\r\n" read-resp ] [ redis-error? ] must-fail-with

! an error nested in an aggregate is returned as a value, not thrown,
! and does not desync the stream (error first, OK second)
{ t } [
    "*2\r\n+OK\r\n-ERR boom\r\n" read-resp second redis-error?
] unit-test

{ t } [
    "*2\r\n-ERR boom\r\n+OK\r\n" read-resp first redis-error?
] unit-test
