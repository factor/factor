! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.limited io.streams.string
io.streams.throwing tools.test kernel ;
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

[
    "asdf" <string-reader> 2 <limited-stream>
    [ 1 seek-absolute seek-input 4 read drop ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[ "asd" CHAR: f ] [
    "asdf" <string-reader>
    [ "f" read-until ] throws-on-eof
] unit-test

[
    "asdf" <string-reader>
    [ "g" read-until ] throws-on-eof
] [ stream-exhausted? ] must-fail-with

[ 1 ] [
    "asdf" <string-reader> 2 <limited-stream>
    [ 1 seek-absolute seek-input tell-input ] throws-on-eof
] unit-test
