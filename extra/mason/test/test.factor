! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs benchmark bootstrap.stage2
compiler.errors generic help.html help.lint io.directories
io.encodings.utf8 io.files kernel mason.common math namespaces
prettyprint sequences sets sorting tools.test tools.time
tools.vocabs words system io ;
IN: mason.test

: do-load ( -- )
    try-everything
    [ keys load-everything-vocabs-file to-file ]
    [ load-everything-errors-file utf8 [ load-failures. ] with-file-writer ]
    bi ;

GENERIC: word-vocabulary ( word -- vocabulary )

M: word word-vocabulary vocabulary>> ;

M: method-body word-vocabulary "method-generic" word-prop word-vocabulary ;

: do-compile-errors ( -- )
    compiler-errors-file utf8 [
        +error+ errors-of-type keys
        [ word-vocabulary ] map
        prune natural-sort .
    ] with-file-writer ;

: do-tests ( -- )
    run-all-tests
    [ keys test-all-vocabs-file to-file ]
    [ test-all-errors-file utf8 [ test-failures. ] with-file-writer ]
    bi ;

: do-help-lint ( -- )
    "" run-help-lint
    [ keys help-lint-vocabs-file to-file ]
    [ help-lint-errors-file utf8 [ typos. ] with-file-writer ]
    bi ;

: do-benchmarks ( -- )
    run-benchmarks benchmarks-file to-file ;

: benchmark-ms ( quot -- ms )
    benchmark 1000 /i ; inline

: check-boot-image ( -- )
    "" to-refresh drop 2dup [ empty? not ] either?
    [
        "Boot image is out of date. Changed vocabs:" print
        append prune [ print ] each
        flush
        1 exit
    ] [ 2drop ] if ;

: do-all ( -- )
    ".." [
        bootstrap-time get boot-time-file to-file
        check-boot-image
        [ do-load do-compile-errors ] benchmark-ms load-time-file to-file
        [ generate-help ] benchmark-ms html-help-time-file to-file
        [ do-tests ] benchmark-ms test-time-file to-file
        [ do-help-lint ] benchmark-ms help-lint-time-file to-file
        [ do-benchmarks ] benchmark-ms benchmark-time-file to-file
    ] with-directory ;

MAIN: do-all