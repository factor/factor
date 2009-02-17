! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry html.parser html.parser.analyzer
http.client kernel tools.time sets assocs sequences
concurrency.combinators io threads namespaces math multiline
heaps math.parser inspector urls assoc-heaps logging
combinators.short-circuit continuations calendar prettyprint ;
IN: spider

TUPLE: spider base count max-count sleep max-depth initial-links
filters spidered todo nonmatching quiet ;

TUPLE: spider-result url depth headers fetch-time parsed-html
links processing-time timestamp ;

: <spider> ( base -- spider )
    >url
    spider new
        over >>base
        swap 0 <unique-min-heap> [ heap-push ] keep >>todo
        <unique-min-heap> >>nonmatching
        0 >>max-depth
        0 >>count
        1/0. >>max-count
        H{ } clone >>spidered ;

<PRIVATE

: apply-filters ( links spider -- links' )
    filters>> [ '[ _ 1&& ] filter ] when* ;

: push-links ( links level assoc-heap -- )
    '[ _ _ heap-push ] each ;

: add-todo ( links level spider -- )
    todo>> push-links ;

: add-nonmatching ( links level spider -- )
    nonmatching>> push-links ;

: filter-base ( spider spider-result -- base-links nonmatching-links )
    [ base>> host>> ] [ links>> prune ] bi*
    [ host>> = ] with partition ;

: add-spidered ( spider spider-result -- )
    [ [ 1+ ] change-count ] dip
    2dup [ spidered>> ] [ dup url>> ] bi* rot set-at
    [ filter-base ] 2keep
    depth>> 1+ swap
    [ add-nonmatching ]
    [ tuck [ apply-filters ] 2dip add-todo ] 2bi ;

: normalize-hrefs ( links -- links' )
    [ >url ] map
    spider get base>> swap [ derive-url ] with map ;

: print-spidering ( url depth -- )
    "depth: " write number>string write
    ", spidering: " write . yield ;

: (spider-page) ( url depth -- spider-result )
    f pick spider get spidered>> set-at
    over '[ _ http-get ] benchmark swap
    [ parse-html dup find-hrefs normalize-hrefs ] benchmark
    now spider-result boa ;

: spider-page ( url depth -- )
    spider get quiet>> [ 2dup print-spidering ] unless
    (spider-page)
    spider get [ quiet>> [ dup describe ] unless ]
    [ swap add-spidered ] bi ;

\ spider-page ERROR add-error-logging

: spider-sleep ( -- )
    spider get sleep>> [ sleep ] when* ;

: queue-initial-links ( spider -- spider )
    [ initial-links>> normalize-hrefs 0 ] keep
    [ add-todo ] keep ;

: slurp-heap-while ( heap quot1 quot2: ( value key -- ) -- )
    pick heap-empty? [ 3drop ] [
        [ [ heap-pop dup ] 2dip slip [ t ] compose [ 2drop f ] if ]
        [ roll [ slurp-heap-while ] [ 3drop ] if ] 3bi
    ] if ; inline recursive

PRIVATE>

: run-spider ( spider -- spider )
    "spider" DEBUG [
        dup spider [
            queue-initial-links
            [ todo>> ] [ max-depth>> ] bi
            '[
                _ <= spider get
                [ count>> ] [ max-count>> ] bi < and
            ] [ spider-page spider-sleep ] slurp-heap-while
            spider get
        ] with-variable
    ] with-logging ;
