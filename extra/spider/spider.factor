! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit
concurrency.semaphores deques html.parser html.parser.analyzer
http.client inspector io io.pathnames kernel logging math
math.parser prettyprint sequences sets spider.unique-deque
threads tools.time urls ;
IN: spider

TUPLE: spider
    base
    { count integer initial: 0 }
    { max-count number initial: 1/0. }
    sleep
    { max-depth integer initial: 0 }
    initial-links
    filters
    spidered
    todo
    nonmatching
    quiet?
    currently-spidering
    { #threads integer initial: 1 }
    semaphore
    follow-robots?
    robots ;

TUPLE: spider-result url depth headers
fetched-in parsed-html links processed-in fetched-at ;

: <spider> ( base -- spider )
    >url
    spider new
        over >>base
        over >>currently-spidering
        swap 0 <unique-deque> [ push-url ] keep >>todo
        <unique-deque> >>nonmatching
        H{ } clone >>spidered
        1 <semaphore> >>semaphore ;

: <spider-result> ( url depth -- spider-result )
    spider-result new
        swap >>depth
        swap >>url ; inline

<PRIVATE

: apply-filters ( links spider -- links' )
    filters>> [
        '[ [ _ 1&& ] filter ] call( seq -- seq' )
    ] when* ;

: push-links ( links level unique-deque -- )
    '[ _ _ push-url ] each ;

: add-todo ( links level spider -- )
    todo>> push-links ;

: add-nonmatching ( links level spider -- )
    nonmatching>> push-links ;

: filter-base-links ( spider spider-result -- base-links nonmatching-links )
    [ base>> host>> ] [ links>> members ] bi*
    [ host>> = ] with partition ;

:: add-spidered ( spider spider-result -- )
    spider [ 1 + ] change-count drop

    spider-result dup url>>
    spider spidered>> set-at

    spider spider-result filter-base-links :> ( matching nonmatching )
    spider-result depth>> 1 + :> depth

    nonmatching depth spider add-nonmatching

    matching spider apply-filters depth spider add-todo ;

: normalize-hrefs ( base links -- links' )
    [ derive-url ] with map ;

: print-spidering ( spider-result -- )
    [ url>> ] [ depth>> ] bi
    "depth: " write number>string write
    ", spidering: " write . yield ;

: url-html? ( url -- ? )
    path>> file-extension { ".htm" ".html" f } member? ;

:: fill-spidered-result ( spider spider-result -- )
    spider-result url>> :> url
    f url spider spidered>> set-at
    [ url http-get ] benchmark :> ( headers html fetched-in )
    [
        url url-html? [
            html parse-html
            spider currently-spidering>>
            over find-all-links normalize-hrefs
        ] [
            f { }
        ] if
    ] benchmark :> ( parsed-html links processed-in )
    spider-result
        headers >>headers
        fetched-in >>fetched-in
        parsed-html >>parsed-html
        links >>links
        processed-in >>processed-in
        now >>fetched-at drop ;

:: spider-page ( spider spider-result -- )
    spider quiet?>> [ spider-result print-spidering ] unless
    spider spider-result fill-spidered-result
    spider quiet?>> [ spider-result describe ] unless
    spider spider-result add-spidered ;

\ spider-page ERROR add-error-logging

: spider-sleep ( spider -- ) sleep>> [ sleep ] when* ;

: queue-initial-links ( spider -- spider )
    [ [ currently-spidering>> ] [ initial-links>> ] bi normalize-hrefs 0 ]
    [ add-todo ]
    [ ] tri ;

: spider-page? ( spider -- ? )
    {
        [ todo>> deque>> deque-empty? not ]
        [ [ todo>> peek-url depth>> ] [ max-depth>> ] bi <= ]
        [ [ count>> ] [ max-count>> ] bi < ]
    } 1&& ;

: setup-next-url ( spider -- spider spider-result )
    dup todo>> peek-url url>> >>currently-spidering
    dup todo>> pop-url [ url>> ] [ depth>> ] bi <spider-result> ;

: spider-next-page ( spider -- )
    setup-next-url
    spider-page ;

PRIVATE>

: run-spider-loop ( spider -- )
    dup spider-page? [
        [ spider-next-page ] [ spider-sleep ] [ run-spider-loop ] tri
    ] [
        drop
    ] if ;

: run-spider ( spider -- spider )
    "spider" [
        queue-initial-links
        [ run-spider-loop ] keep
    ] with-logging ;
