! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators html kernel math
math.statistics namespaces sequences sorting urls xml.syntax ;
IN: spider.report

SYMBOL: network-failures
SYMBOL: broken-pages
SYMBOL: timings

: record-broken-page ( url spider-result -- )
    headers>> [ code>> ] [ message>> ] bi 2array 2array
    broken-pages push ;

: record-page-timings ( url spider-result -- )
    fetched-in>> 2array timings get push ;

: record-network-failure ( url -- )
    network-failures get push ;

: process-result ( url spider-result -- )
    {
        { f [ record-network-failure ] }
        [
            dup headers>> code>> 200 =
            [ record-page-timings ] [ record-broken-page ] if
        ]
    } case ;

CONSTANT: slowest 5

SYMBOL: slowest-pages
SYMBOL: mean-time
SYMBOL: median-time
SYMBOL: time-std

: process-timings ( -- )
    timings get sort-values
    [ slowest index-or-length tail* reverse slowest-pages set ]
    [
        values [
            [ mean 1000000 /f mean-time set ]
            [ median 1000000 /f median-time set ]
            [ std 1000000 /f time-std set ] tri
        ] unless-empty
    ] bi ;

: process-results ( results -- )
    V{ } clone network-failures set
    V{ } clone broken-pages set
    V{ } clone timings set
    [ process-result ] assoc-each
    process-timings ;

: info-table ( alist -- html )
    [
        first2 dupd 1000000 /f
        [XML
        <tr><td><a href=<->><-></a></td><td><-> seconds</td></tr>
        XML]
    ] map [XML <table border="1"><-></table> XML] ;

: report-broken-pages ( -- html )
    broken-pages get info-table ;

: report-network-failures ( -- html )
    network-failures get [
        dup [XML <li><a href=<->><-></a></li> XML]
    ] map [XML <ul><-></ul> XML] ;

: slowest-pages-table ( -- html )
    slowest-pages get info-table ;

: timing-summary-table ( -- html )
    mean-time get
    median-time get
    time-std get
    [XML
    <table border="1">
    <tr><th>Mean</th><td><-> seconds</td></tr>
    <tr><th>Median</th><td><-> seconds</td></tr>
    <tr><th>Standard deviation</th><td><-> seconds</td></tr>
    </table>
    XML] ;

: report-timings ( -- html )
    slowest-pages-table
    timing-summary-table
    [XML
    <h3>Slowest pages</h3>
    <->

    <h3>Summary</h3>
    <->
    XML] ;

: generate-report ( -- html )
    url get dup
    report-broken-pages
    report-network-failures
    report-timings
    [XML
    <h1>Spider report</h1>
    URL: <a href=<->><-></a>

    <h2>Broken pages</h2>
    <->

    <h2>Network failures</h2>
    <->

    <h2>Load times</h2>
    <->
    XML] ;

: spider-report ( spider -- html )
    [ "Spider report" f ] dip
    [
        [ base>> url set ]
        [ spidered>> process-results ] bi
        generate-report
    ] with-scope
    simple-page ;
