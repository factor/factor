USING: accessors io kernel math parser tools.test words ;
IN: io.tests

{ f } [
    "vocab:io/test/no-trailing-eol.factor" run-file
    "foo" "io.tests" lookup
] unit-test

! Make sure we use correct to_c_string form when writing
{ } [ "\0" write ] unit-test

! Test default input stream protocol methods

TUPLE: up-to-13-reader { i fixnum initial: 0 } ;

M: up-to-13-reader stream-element-type drop +byte+ ; inline
M: up-to-13-reader stream-read1
    [ dup 1 + ] change-i drop
    dup 13 >= [ drop f ] when ; inline

{ B{ 0 1 2 } } [ 3 up-to-13-reader new stream-read ] unit-test
{ B{ 0 1 2 } } [ 3 up-to-13-reader new stream-read-partial ] unit-test

{ B{ 0 1 2 3 4 5 6 7 8 9 10 11 12 } f }
[ up-to-13-reader new [ 20 swap stream-read ] [ 20 swap stream-read ] bi ] unit-test


{
    B{ 0 1 2 3 4 5 6 7 8 } 9
    B{ 10 11 12 } f
    f f
} [
    up-to-13-reader new
    [ "\t" swap stream-read-until ]
    [ "\t" swap stream-read-until ]
    [ "\t" swap stream-read-until ] tri
] unit-test

{ B{ 0 1 2 3 4 5 6 7 8 9 } B{ 11 12 } f } [
    up-to-13-reader new
    [ stream-readln ] [ stream-readln ] [ stream-readln ] tri
] unit-test

! Test default output stream protocol methods

TUPLE: dumb-writer vector ;

: <dumb-writer> ( -- x ) BV{ } clone dumb-writer boa ; inline

M: dumb-writer stream-element-type drop +byte+ ; inline
M: dumb-writer stream-write1 vector>> push ; inline

{ BV{ 11 22 33 } } [
    <dumb-writer> 
    [ B{ 11 22 33 } swap stream-write ]
    [ vector>> ] bi
] unit-test

{ BV{ 11 22 33 10 } } [
    <dumb-writer> 
    [ B{ 11 22 33 } swap stream-write ]
    [ stream-nl ]
    [ vector>> ] tri
] unit-test
