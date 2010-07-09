! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.limited io.streams.string
io.streams.throwing tools.test ;
IN: io.streams.throwing.tests

[ "as" ]
[
    "asdf" <string-reader> 2 <limited-stream>
    [ 6 read-partial ] throws-on-eof
] unit-test

[
    "asdf" <string-reader> 2 <limited-stream>
    [ contents ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[
    "asdf" <string-reader> 2 <limited-stream>
    [ 2 read read1 ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[
    "asdf" <string-reader> 2 <limited-stream>
    [ 3 read ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[
    "asdf" <string-reader> 2 <limited-stream>
    [ 2 read 2 read ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[
    "asdf" <string-reader> 2 <limited-stream>
    [ contents contents ] throws-on-eof
] [ stream-exhausted? ] must-fail-with
