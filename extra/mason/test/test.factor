! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs benchmark bootstrap.stage2 compiler.errors
source-files.errors generic help.html help.lint io.directories
io.encodings.utf8 io.files kernel mason.common math namespaces
prettyprint sequences sets sorting tools.test tools.time
words system io tools.errors vocabs.hierarchy vocabs.errors
vocabs.refresh locals ;
IN: mason.test

: do-load ( -- )
    "" (load)
    [ keys load-all-vocabs-file to-file ]
    [ load-all-errors-file utf8 [ load-failures. ] with-file-writer ]
    bi ;

GENERIC: word-vocabulary ( word -- vocabulary )

M: word word-vocabulary vocabulary>> ;

M: method word-vocabulary "method-generic" word-prop word-vocabulary ;

:: do-step ( errors summary-file details-file -- )
    errors
    [ error-type +linkage-error+ eq? not ] filter
    [ file>> ] map prune natural-sort summary-file to-file
    errors details-file utf8 [ errors. ] with-file-writer ;

: do-tests ( -- )
    test-all test-failures get
    test-all-vocabs-file
    test-all-errors-file
    do-step ;

: do-help-lint ( -- )
    help-lint-all lint-failures get values
    help-lint-vocabs-file
    help-lint-errors-file
    do-step ;

: do-benchmarks ( -- )
    run-benchmarks
    [ benchmarks-file to-file ] [
        [ keys benchmark-error-vocabs-file to-file ]
        [ benchmark-error-messages-file utf8 [ benchmark-errors. ] with-file-writer ] bi
    ] bi* ;

: do-compile-errors ( -- )
    compiler-errors get values
    compiler-errors-file
    compiler-error-messages-file
    do-step ;

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
        [ do-load ] benchmark load-time-file to-file
        [ generate-help ] benchmark html-help-time-file to-file
        [ do-tests ] benchmark test-time-file to-file
        [ do-help-lint ] benchmark help-lint-time-file to-file
        [ do-benchmarks ] benchmark benchmark-time-file to-file
        do-compile-errors
    ] with-directory ;

MAIN: do-all
