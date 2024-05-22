! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators.smart debugger formatting
io.encodings.utf8 io.files io.streams.string kernel literals
mason.common mason.config mason.disk math namespaces prettyprint
sequences sets splitting xml.syntax xml.writer ;
IN: mason.report

: git-id>url ( id -- github-url )
    "https://github.com/factor/factor/commit/" "" prepend-as ; inline

: git-short-link ( id -- short-link )
    [ git-id>url ] keep 8 head "…" append [XML <a href=<->><-></a> XML] ;

: git-link ( id -- link )
    [ git-id>url ] keep [XML <a href=<->><-></a> XML] ;

: common-report ( -- xml )
    target-os get
    target-cpu get
    short-host-name
    disk-usage
    build-dir
    current-git-id get git-link
    [XML
    <h1>Build report for <->/<-></h1>
    <table>
    <tr><td>Build machine:</td><td><-></td></tr>
    <tr><td>Disk usage:</td><td><-></td></tr>
    <tr><td>Build directory:</td><td><-></td></tr>
    <tr><td>GIT ID:</td><td><-></td></tr>
    </table>
    XML] ;

: with-report ( quot: ( -- xml ) -- )
    [ "report" utf8 ] dip
    '[
        common-report
        _ call( -- xml )
        [XML <div><-><-></div> XML]
        write-xml
    ] with-file-writer ; inline

: file-tail ( file encoding lines -- seq )
    [ file-lines ] dip index-or-length tail* join-lines ;

:: failed-report ( error file what -- status )
    [
        error [ error. ] with-string-writer :> error
        file utf8 400 file-tail :> output

        [XML
        <h2><-what-></h2>
        Build output:
        <pre><-output-></pre>
        Launcher error:
        <pre><-error-></pre>
        XML]
    ] with-report
    status-error ;

: compile-failed ( error -- status )
    "compile-log" "VM compilation failed" failed-report ;

: boot-failed ( error -- status )
    "boot-log" "Bootstrap failed" failed-report ;

: test-failed ( error -- status )
    "test-log" "Tests failed" failed-report ;

: timings-table ( -- xml )
    ${
        boot-time-file
        load-time-file
        test-time-file
        help-lint-time-file
        benchmark-time-file
        html-help-time-file
    } [
        dup eval-file nanos>time
        [XML <tr><td><-></td><td><-></td></tr> XML]
    ] map [XML <h2>Timings</h2> <table><-></table> XML] ;

: error-dump ( heading vocabs-file messages-file -- xml )
    [ eval-file ] dip over empty? [ 3drop f ] [
        [ ]
        [ [ [XML <li><-></li> XML] ] map [XML <ul><-></ul> XML] ]
        [ utf8 file-contents ]
        tri*
        [XML <h1><-></h1> <-> Details: <pre><-></pre> XML]
    ] if ;

: benchmarks-table ( assoc -- xml )
    [
        1,000,000,000 /f "%.3f" sprintf
        [XML <tr><td><-></td><td><-></td></tr> XML]
    ] { } assoc>map
    [XML
        <h2>Benchmarks</h2>
        <table>
            <tr><th>Benchmark</th><th>Time (seconds)</th></tr>
            <->
        </table>
    XML] ;

: successful-report ( -- )
    [
        [
            timings-table

            "Load failures"
            load-all-vocabs-file
            load-all-errors-file
            error-dump

            "Compiler errors"
            compiler-errors-file
            compiler-error-messages-file
            error-dump

            "Unit test failures"
            test-all-vocabs-file
            test-all-errors-file
            error-dump

            "Help lint failures"
            help-lint-vocabs-file
            help-lint-errors-file
            error-dump

            "Benchmark errors"
            benchmark-error-vocabs-file
            benchmark-error-messages-file
            error-dump

            benchmarks-file eval-file benchmarks-table
        ] output>array sift
    ] with-report ;

: benchmark-results ( -- assoc )
    ${
        boot-time-file
        load-time-file
        test-time-file
        help-lint-time-file
        benchmark-time-file
        html-help-time-file
    } [
        dup eval-file 2array
    ] map
    benchmarks-file eval-file
    union ;

: successful-benchmarks ( -- )
    "benchmark-results" utf8 [ benchmark-results ... ] with-file-writer ;

: build-clean? ( -- ? )
    ${
        load-all-vocabs-file
        test-all-vocabs-file
        help-lint-vocabs-file
        compiler-errors-file
        benchmark-error-vocabs-file
    } [ eval-file empty? ] all? ;

: success ( -- status )
    successful-report build-clean? [ successful-benchmarks status-clean ] [ status-dirty ] if ;
