! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: benchmark combinators.smart debugger fry io assocs
io.encodings.utf8 io.files io.sockets io.streams.string kernel
locals mason.common mason.config mason.platform math namespaces
prettyprint sequences xml.syntax xml.writer ;
IN: mason.report

: common-report ( -- xml )
    target-os get
    target-cpu get
    host-name
    build-dir
    "git-id" eval-file
    [XML
    <h1>Build report for <->/<-></h1>
    <table>
    <tr><td>Build machine:</td><td><-></td></tr>
    <tr><td>Build directory:</td><td><-></td></tr>
    <tr><td>GIT ID:</td><td><-></td></tr>
    </table>
    XML] ;

: with-report ( quot -- )
    [ "report" utf8 ] dip
    '[
        common-report
        _ call( -- xml )
        [XML <html><body><-><-></body></html> XML]
        pprint-xml
    ] with-file-writer ; inline

:: failed-report ( error file what -- )
    [
        error [ error. ] with-string-writer :> error
        file utf8 file-contents 400 short tail* :> output
        
        [XML
        <h2><-what-></h2>
        Build output:
        <pre><-output-></pre>
        Launcher error:
        <pre><-error-></pre>
        XML]
    ] with-report ;

: compile-failed-report ( error -- )
    "compile-log" "VM compilation failed" failed-report ;

: boot-failed-report ( error -- )
    "boot-log" "Bootstrap failed" failed-report ;

: test-failed-report ( error -- )
    "test-log" "Tests failed" failed-report ;

: timings-table ( -- xml )
    {
        boot-time-file
        load-time-file
        test-time-file
        help-lint-time-file
        benchmark-time-file
        html-help-time-file
    } [
        dup utf8 file-contents milli-seconds>time
        [XML <tr><td><-></td><td><-></td></tr> XML]
    ] map [XML <h2>Timings</h2> <table><-></table> XML] ;

: fail-dump ( heading vocabs-file messages-file -- xml )
    [ eval-file ] dip over empty? [ 3drop f ] [
        [ ]
        [ [ [XML <li><-></li> XML] ] map [XML <ul><-></ul> XML] ]
        [ utf8 file-contents ]
        tri*
        [XML <h1><-></h1> <-> Details: <pre><-></pre> XML]
    ] if ;

: benchmarks-table ( assoc -- xml )
    [
        1000000 /f
        [XML <tr><td><-></td><td><-></td></tr> XML]
    ] { } assoc>map [XML <h2>Benchmarks</h2> <table><-></table> XML] ;

: successful-report ( -- )
    [
        [
            timings-table

            "Load failures"
            load-everything-vocabs-file
            load-everything-errors-file
            fail-dump

            "Compiler warnings and errors"
            compiler-errors-file
            compiler-error-messages-file
            fail-dump

            "Unit test failures"
            test-all-vocabs-file
            test-all-errors-file
            fail-dump
            
            "Help lint failures"
            help-lint-vocabs-file
            help-lint-errors-file
            fail-dump

            "Benchmark errors"
            benchmark-error-vocabs-file
            benchmark-error-messages-file
            fail-dump
            
            "Benchmark timings"
            benchmarks-file eval-file benchmarks-table
        ] output>array
    ] with-report ;