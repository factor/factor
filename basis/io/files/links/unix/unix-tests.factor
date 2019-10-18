USING: io.directories io.files.links tools.test sequences
io.files.unique tools.files fry math kernel math.parser
io.pathnames namespaces ;
IN: io.files.links.unix.tests

: make-test-links ( n path -- )
    [ '[ [ 1 + ] keep [ number>string _ prepend ] bi@ make-link ] each-integer ]
    [ [ number>string ] dip prepend touch-file ] 2bi ; inline

[ t ] [
    [
        current-temporary-directory get [
            5 "lol" make-test-links
            "lol1" follow-links
            current-temporary-directory get "lol5" append-path =
        ] with-directory
    ] cleanup-unique-directory
] unit-test

[
    [
        current-temporary-directory get [
            100 "laf" make-test-links "laf1" follow-links
        ] with-directory
    ] with-unique-directory
] [ too-many-symlinks? ] must-fail-with

[ t ] [
    110 symlink-depth [
        [
            current-temporary-directory get [
                100 "laf" make-test-links
                "laf1" follow-links
                current-temporary-directory get "laf100" append-path =
            ] with-directory
        ] cleanup-unique-directory
    ] with-variable
] unit-test
