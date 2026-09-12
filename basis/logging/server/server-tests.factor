USING: arrays continuations io.directories io.encodings.utf8 io.files
io.files.temp io.files.unique io.pathnames kernel locals logging.server math
math.parser namespaces sequences splitting tools.test ;
IN: logging.server.tests

:: with-small-logs ( quot -- )
    max-log-size get-global :> old-limit
    [
        1 max-log-size set-global
        [
            [ current-directory get quot with-log-root ] cleanup-unique-directory
        ] with-temp-directory
    ] [ old-limit max-log-size set-global ] finally ; inline

: test-message ( text service -- )
    [ 1array "test" "NOTICE" ] dip 4array (log-message) ;

: log-text ( service n -- string )
    [ log-path ] dip log# utf8 file-contents ;

{ t t t t } [
    [
        "first" "one" test-message
        "other" "two" test-message
        "second" "one" test-message
        "third" "one" test-message
        "one" 1 log-text "third\n" tail?
        "one" 2 log-text "second\n" tail?
        "one" 3 log-text "first\n" tail?
        "two" 1 log-text "other\n" tail?
    ] with-small-logs
] unit-test

! An existing oversized log is preserved before the first new message.
{ "old backlog" t } [
    [
        "one" log-path make-directories
        "old backlog" "one" log-path 1 log# utf8 set-file-contents
        "new" "one" test-message
        "one" 2 log-text
        "one" 1 log-text "new\n" tail?
    ] with-small-logs
] unit-test

{ 10 t t } [
    [
        12 [ number>string "one" test-message ] each-integer
        "one" log-path directory-files length
        "one" 1 log-text "test: 11\n" tail?
        "one" 10 log-text "test: 2\n" tail?
    ] with-small-logs
] unit-test

! A multiline entry stays together even when it exceeds the rotation size.
{ t t } [
    [
        { { "first" "second" } "test" "ERROR" "one" } (log-message)
        "third" "one" test-message
        "one" 2 log-text "second\n" tail?
        "one" 1 log-text "third\n" tail?
    ] with-small-logs
] unit-test
