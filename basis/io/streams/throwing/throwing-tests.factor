! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays destructors io io.encodings.binary
io.encodings.utf8 io.files io.streams.byte-array
io.streams.string io.streams.throwing kernel namespaces
sequences tools.test ;

{ "asdf" }
[
    "asdf" [ [ 6 read-partial ] throw-on-eof ] with-string-reader
] unit-test

[
    "asdf" [ [ 4 read read1 ] throw-on-eof ] with-string-reader
] [ stream-exhausted? ] must-fail-with

[
    [
        "asdf" <string-reader> [
            4 read read1
        ] stream-throw-on-eof
    ] with-destructors
] [ stream-exhausted? ] must-fail-with

[
    "asdf" [ [ 5 read ] throw-on-eof ] with-string-reader
] [ stream-exhausted? ] must-fail-with

[
    "asdf" [ [ 4 read 4 read ] throw-on-eof ] with-string-reader
] [ stream-exhausted? ] must-fail-with

{ "as" "df" } [
    "asdf" [ [ 2 read ] throw-on-eof 3 read ] with-string-reader
] unit-test

{ t } [
    "vocab:io/streams/throwing/asdf.txt" utf8 [
        [ 2 read ] throw-on-eof 20 read
    ] with-file-reader
    ! For Windows line endings
    2array {
        { "as" "df\n" }
        { "as" "df\r\n" }
    } member?
] unit-test

{ B{ 0 1 2 3 } B{ 0 1 2 3 } } [
    B{ 0 1 2 3 } binary [
        [ 4 read 0 seek-absolute seek-input 4 read ] throw-on-eof
    ] with-byte-reader
] unit-test

[
    B{ 0 1 2 3 } binary [
        [ 1 seek-absolute seek-input 4 read drop ] throw-on-eof
    ] with-byte-reader
] [ stream-exhausted? ] must-fail-with

{ "asd" CHAR: f } [
    "asdf" [ [ "f" read-until ] throw-on-eof ] with-string-reader
] unit-test

[
    "asdf" [ [ "g" read-until ] throw-on-eof ] with-string-reader
] [ stream-exhausted? ] must-fail-with

{ 1 } [
    B{ 0 1 2 3 } binary [
        [ 1 seek-absolute seek-input tell-input ] throw-on-eof
    ] with-byte-reader
] unit-test

{ t 4 } [
    B{ 0 1 2 3 } binary [ [
        input-stream get [ stream-seekable? ] [ stream-length ] bi
    ] throw-on-eof ] with-byte-reader
] unit-test
