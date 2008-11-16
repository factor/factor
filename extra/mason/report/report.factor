! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces debugger fry io io.files io.sockets
io.encodings.utf8 prettyprint benchmark mason.common
mason.platform mason.config ;
IN: mason.report

: time. ( file -- )
    [ write ": " write ] [ eval-file milli-seconds>time print ] bi ;

: common-report ( -- )
    "Build machine: " write host-name print
    "CPU: " write target-cpu get print
    "OS: " write target-os get print
    "Build directory: " write build-dir print
    "git id: " write "git-id" eval-file print nl ;

: with-report ( quot -- )
    [ "report" utf8 ] dip '[ common-report @ ] with-file-writer ;

: compile-failed-report ( error -- )
    [
        "VM compile failed:" print nl
        "compile-log" cat nl
        error.
    ] with-report ;

: boot-failed-report ( error -- )
    [
        "Bootstrap failed:" print nl
        "boot-log" 100 cat-n nl
        error.
    ] with-report ;

: test-failed-report ( error -- )
    [
        "Tests failed:" print nl
        "test-log" 100 cat-n nl
        error.
    ] with-report ;

: successful-report ( -- )
    [
        boot-time-file time.
        load-time-file time.
        test-time-file time.
        help-lint-time-file time.
        benchmark-time-file time.
        html-help-time-file time.

        nl

        "Did not pass load-everything:" print
        load-everything-vocabs-file cat
        load-everything-errors-file cat

        "Did not pass test-all:" print
        test-all-vocabs-file cat
        test-all-errors-file cat

        "Did not pass help-lint:" print
        help-lint-vocabs-file cat
        help-lint-errors-file cat

        "Benchmarks:" print
        benchmarks-file eval-file benchmarks.
    ] with-report ;