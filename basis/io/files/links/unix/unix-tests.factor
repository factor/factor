USING: fry io.directories io.files.links io.pathnames kernel
math math.parser namespaces sequences tools.test ;
IN: io.files.links.unix.tests

: make-test-links ( n path -- )
    [ '[ [ 1 + ] keep [ number>string _ prepend ] bi@ make-link ] each-integer ]
    [ [ number>string ] dip prepend touch-file ] 2bi ; inline

{ t } [
    [
        5 "lol" make-test-links
        "lol1" follow-links
        "lol5" absolute-path =
    ] with-test-directory
] unit-test

[
    [
        100 "laf" make-test-links "laf1" follow-links
    ] with-test-directory
] [ too-many-symlinks? ] must-fail-with

{ t } [
    110 symlink-depth [
        [
            100 "laf" make-test-links
            "laf1" follow-links
            "laf100" absolute-path =
        ] with-test-directory
    ] with-variable
] unit-test
