! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs benchmark bootstrap.stage2 calendar
command-line compiler.errors continuations debugger help.html
help.lint io io.directories io.encodings.utf8 io.files io.styles
kernel mason.common math memory namespaces parser.notes
sequences sets sorting source-files.errors system threads
tools.errors tools.test tools.time vocabs
vocabs.hierarchy.private vocabs.loader vocabs.refresh ;
IN: mason.test

: vocab-heading. ( vocab -- )
    nl
    "==== " write
    [ vocab-name ] [ lookup-vocab write-object ] bi ":" print
    nl ;

: load-error. ( triple -- )
    [ first vocab-heading. ] [ second print-error ] bi ;

: load-failures. ( failures -- ) [ load-error. nl ] each ;

: require-all-no-restarts ( vocabs -- failures )
    V{ } clone [
        '[
            [ require ]
            [ swap vocab-name _ set-at ] recover
        ] each
    ] keep ;

: load-from-root-no-restarts ( root prefix -- failures )
    vocabs-to-load require-all-no-restarts ;

: load-no-restarts ( prefix -- failures )
    [ vocab-roots get dup ] dip '[
        _ swap 1 + head vocab-roots [
            _ load-from-root-no-restarts
        ] with-variable
    ] map-index concat ;

: do-load ( -- )
    "" load-no-restarts
    [ keys load-all-vocabs-file to-file ]
    [ load-all-errors-file utf8 [ load-failures. ] with-file-writer ]
    bi ;

:: do-step ( errors summary-file details-file -- )
    errors
    [ error-type +linkage-error+ eq? ] reject
    [ path>> ] map members sort summary-file to-file
    errors details-file utf8 [ errors. ] with-file-writer ;

: do-tests ( -- )
    forget-tests? on
    cpu x86.32? [
        "resource:core" test-root
        "resource:basis" test-root
    ] [
        test-all
    ] if
    test-failures get
    test-all-vocabs-file
    test-all-errors-file
    do-step ;

: do-help-lint ( -- )
    help-lint-all
    ! Give the cleanup a chance to run before looking at the errors.
    gc 2 seconds sleep
    lint-failures get values
    help-lint-vocabs-file
    help-lint-errors-file
    do-step ;

: do-benchmarks ( -- )
    { } { } ! run-timing-benchmarks
    [ benchmarks-file to-file ] [
        [ keys benchmark-error-vocabs-file to-file ]
        [ benchmark-error-messages-file utf8 [ benchmark-errors. ] with-file-writer ] bi
    ] bi* ;

: do-compile-errors ( -- )
    compiler-errors get values
    compiler-errors-file
    compiler-error-messages-file
    do-step ;

: outdated-core-vocabs ( -- modified-sources modified-docs any? )
    "" to-refresh drop 2dup [ empty? not ] either? ;

: outdated-boot-image. ( modified-sources modified-docs -- )
    "Boot image is out of date. Changed vocabs:" print
    union write-lines flush ;

: check-boot-image ( -- ? )
    outdated-core-vocabs [ outdated-boot-image. t ] [ 2drop f ] if ;

: run-mason-rc ( -- )
    t "user-init" [
        "~/.factor-mason-rc" try-user-init
    ] with-variable ;

: check-user-init-errors ( -- ? )
    user-init-errors get-global assoc-empty?
    [ f ] [ :user-init-errors t ] if ;

: do-all ( -- )
    f parser-quiet? set-global
    f restartable-tests? set-global
    ".." [
        run-mason-rc check-user-init-errors [ 1 exit ] when
        bootstrap-time get boot-time-file to-file
        check-boot-image [ 1 exit ] when
        [ do-load ] benchmark load-time-file to-file
        [ generate-help ] benchmark html-help-time-file to-file
        [ do-tests ] benchmark test-time-file to-file
        [ do-help-lint ] benchmark help-lint-time-file to-file
        [ do-benchmarks ] benchmark benchmark-time-file to-file
        do-compile-errors
    ] with-directory ;

MAIN: do-all
