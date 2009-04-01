! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry html.parser html.parser.analyzer
http.client kernel tools.time sets assocs sequences
concurrency.combinators io threads namespaces math multiline
math.parser inspector urls logging combinators.short-circuit
continuations calendar prettyprint dlists deques locals
present ;
IN: spider

TUPLE: spider base count max-count sleep max-depth initial-links
filters spidered todo nonmatching quiet currently-spidering ;

TUPLE: spider-result url depth headers fetch-time parsed-html
links processing-time timestamp ;

TUPLE: todo-url url depth ;

: <todo-url> ( url depth -- todo-url )
    todo-url new
        swap >>depth
        swap >>url ;

TUPLE: unique-deque assoc deque ;

: <unique-deque> ( -- unique-deque )
    H{ } clone <dlist> unique-deque boa ;

: url-exists? ( url unique-deque -- ? )
    [ url>> ] [ assoc>> ] bi* key? ;

: push-url ( url depth unique-deque -- )
    [ <todo-url> ] dip 2dup url-exists? [
        2drop
    ] [
        [ [ [ t ] dip url>> ] [ assoc>> ] bi* set-at ]
        [ deque>> push-back ] 2bi
    ] if ;

: pop-url ( unique-deque -- todo-url ) deque>> pop-front ;

: peek-url ( unique-deque -- todo-url ) deque>> peek-front ;

: <spider> ( base -- spider )
    >url
    spider new
        over >>base
        over >>currently-spidering
        swap 0 <unique-deque> [ push-url ] keep >>todo
        <unique-deque> >>nonmatching
        0 >>max-depth
        0 >>count
        1/0. >>max-count
        H{ } clone >>spidered ;

<PRIVATE

: apply-filters ( links spider -- links' )
    filters>> [ '[ [ _ 1&& ] filter ] call( seq -- seq' ) ] when* ;

: push-links ( links level unique-deque -- )
    '[ _ _ push-url ] each ;

: add-todo ( links level spider -- )
    todo>> push-links ;

: add-nonmatching ( links level spider -- )
    nonmatching>> push-links ;

: filter-base-links ( spider spider-result -- base-links nonmatching-links )
    [ base>> host>> ] [ links>> prune ] bi*
    [ host>> = ] with partition ;

: add-spidered ( spider spider-result -- )
    [ [ 1+ ] change-count ] dip
    2dup [ spidered>> ] [ dup url>> ] bi* rot set-at
    [ filter-base-links ] 2keep
    depth>> 1+ swap
    [ add-nonmatching ]
    [ tuck [ apply-filters ] 2dip add-todo ] 2bi ;

: url-absolute? ( url -- ? )
    present "http://" head? ;

: normalize-hrefs ( links spider -- links' )
    currently-spidering>> present swap
    [ dup url-absolute? [ derive-url ] [ url-append-path >url ] if ] with map ;

: print-spidering ( url depth -- )
    "depth: " write number>string write
    ", spidering: " write . yield ;

:: new-spidered-result ( spider url depth -- spider-result )
    f url spider spidered>> set-at
    [ url http-get ] benchmark :> fetch-time :> html :> headers
    [
        html parse-html [ ] [ find-all-links spider normalize-hrefs ] bi
    ] benchmark :> processing-time :> links :> parsed-html
    url depth headers fetch-time parsed-html links processing-time
    now spider-result boa ;

:: spider-page ( spider url depth -- )
    spider quiet>> [ url depth print-spidering ] unless
    spider url depth new-spidered-result :> spidered-result
    spider quiet>> [ spidered-result describe ] unless
    spider spidered-result add-spidered ;

\ spider-page ERROR add-error-logging

: spider-sleep ( spider -- )
    sleep>> [ sleep ] when* ;

:: queue-initial-links ( spider -- spider )
    spider initial-links>> spider normalize-hrefs 0 spider add-todo spider ;

: spider-page? ( spider -- ? )
    {
        [ todo>> deque>> deque-empty? not ]
        [ [ todo>> peek-url depth>> ] [ max-depth>> ] bi < ]
        [ [ count>> ] [ max-count>> ] bi < ]
    } 1&& ;

: setup-next-url ( spider -- spider url depth )
    dup todo>> peek-url url>> present >>currently-spidering
    dup todo>> pop-url [ url>> ] [ depth>> ] bi ;

: spider-next-page ( spider -- )
    setup-next-url spider-page ;

PRIVATE>

: run-spider-loop ( spider -- )
    dup spider-page? [
        [ spider-next-page ] [ spider-sleep ] [ run-spider-loop ] tri
    ] [
        drop
    ] if ;

: run-spider ( spider -- spider )
    "spider" [
        queue-initial-links [ run-spider-loop ] keep
    ] with-logging ;
