USING: accessors arrays io.encodings.utf8 io.files io.files.temp
io.files.unique kernel locals logging.parser sequences tools.test ;
IN: logging.parser.tests

:: tail-fixture ( text limit -- lines omitted )
    [
        "log-tail" ".log" [| path |
            text path utf8 set-file-contents
            path limit log-file-tail
        ] cleanup-unique-file
    ] with-temp-directory ;

{ { "old" "λ" "last" } 0 } [ "old\nλ\nlast\n" 100 tail-fixture ] unit-test
{ { "λ" "last" } 4 } [ "old\nλ\nlast\n" 8 tail-fixture ] unit-test
! The tail begins inside the two-byte lambda; do not decode its second byte.
{ { "last" } 7 } [ "old\nλ\nlast\n" 7 tail-fixture ] unit-test
{ { "last" } 7 } [ "old\nλ\nlast\n" 5 tail-fixture ] unit-test
{ { } 12 } [ "old\nλ\nlast\n" 4 tail-fixture ] unit-test
{ { } 6 } [ "abcdef" 3 tail-fixture ] unit-test
{ { "last" } 0 } [ "last" 4 tail-fixture ] unit-test
{ { } 0 } [ "" 4 tail-fixture ] unit-test

[ "unused" 0 log-file-tail ] [ invalid-log-tail-limit? ] must-fail-with
[ "unused" -1 log-file-tail ] [ invalid-log-tail-limit? ] must-fail-with
[ "unused" f log-file-tail ] [ invalid-log-tail-limit? ] must-fail-with

{ 1 { "first" "second" } } [
    {
        "[2026-09-12T14:00:00Z] ERROR failed: first"
        "[--------------------] ERROR failed: second"
    } parse-log [ length ] [ first message>> >array ] bi
] unit-test
