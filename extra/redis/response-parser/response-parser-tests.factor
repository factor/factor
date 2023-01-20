! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test redis.response-parser io.streams.string ;
IN: redis.response-parser.tests

{ 1 } [ ":1\r\n" [ read-response ] with-string-reader ] unit-test

{ "hello" } [ "$5\r\nhello\r\n" [ read-response ] with-string-reader ] unit-test

{ f } [ "$-1\r\n" [ read-response ] with-string-reader ] unit-test

{ { "hello" "world!" } } [
    "*2\r\n$5\r\nhello\r\n$6\r\nworld!\r\n" [ read-response ] with-string-reader
] unit-test

{ { "hello" f "world!" } } [
    "*3\r\n$5\r\nhello\r\n$-1\r\n$6\r\nworld!\r\n" [
        read-response
    ] with-string-reader
] unit-test
