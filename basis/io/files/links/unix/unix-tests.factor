USING: io.directories io.files.links tools.test sequences
io.files.temp io.files.unique tools.files fry math kernel
math.parser io.pathnames namespaces ;
IN: io.files.links.unix.tests

: make-test-links ( n path -- )
    [ '[ [ 1 + ] keep [ number>string _ prepend ] bi@ make-link ] each-integer ]
    [ [ number>string ] dip prepend touch-file ] 2bi ; inline

{ t } [
    [
        [
            5 "lol" make-test-links
            "lol1" follow-links
            "lol5" absolute-path =
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test

[
    [
        [
            100 "laf" make-test-links "laf1" follow-links
        ] with-unique-directory
    ] with-temp-directory
] [ too-many-symlinks? ] must-fail-with

{ t } [
    110 symlink-depth [
        [
            [
                100 "laf" make-test-links
                "laf1" follow-links
                "laf100" absolute-path =
            ] cleanup-unique-directory
        ] with-temp-directory
    ] with-variable
] unit-test
