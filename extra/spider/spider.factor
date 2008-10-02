! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry html.parser html.parser.analyzer
http.client kernel tools.time sets assocs sequences
concurrency.combinators io threads namespaces math multiline
heaps math.parser inspector urls assoc-deques logging
combinators.short-circuit continuations calendar prettyprint ;
IN: spider

TUPLE: spider base count max-count sleep max-depth initial-links
filters spidered todo nonmatching ;
! secure? agent page-timeout data-timeout overall-timeout

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

: add-todo ( links level spider -- )
    tuck [ apply-filters ] 2dip
    tuck
    [ spidered>> keys diff ]
    [ todo>> ] 2bi* '[ _ _ heap-push ] each ;

: add-nonmatching ( links level spider -- )
    nonmatching>> '[ _ _ heap-push ] each ;

: relative-url? ( url -- ? ) protocol>> not ;

: filter-base ( spider spider-result -- base-links nonmatching-links )
    [ base>> host>> ] [ links>> prune ] bi*
    [ host>> = ] with partition ;

: add-spidered ( spider spider-result -- )
    [ [ 1+ ] change-count ] dip
    2dup [ spidered>> ] [ dup url>> ] bi* rot set-at
    [ filter-base ] 2keep
    depth>> 1+ swap
    [ add-nonmatching ]
    [ add-todo ] 2bi ;

: print-spidering ( url depth -- )
    "depth: " write number>string write
    ", spidering: " write . yield ;

: normalize-hrefs ( links -- links' )
    [ >url ] map
    spider get base>> swap [ derive-url ] with map ;

: (spider-page) ( url depth -- spider-result )
    2dup print-spidering
    f pick spider get spidered>> set-at
    over '[ _ http-get ] benchmark swap
    [ parse-html dup find-hrefs normalize-hrefs ] benchmark
    now spider-result boa
    dup describe ;

: spider-page ( url depth -- )
    (spider-page) spider get swap add-spidered ;

\ spider-page ERROR add-error-logging

: spider-sleep ( -- )
    spider get sleep>> [ sleep ] when* ;

: queue-initial-links ( spider -- spider )
    [ initial-links>> normalize-hrefs 0 ] keep
    [ add-todo ] keep ;

PRIVATE>

: run-spider ( spider -- spider )
    "spider" [
        dup spider [
            queue-initial-links
            [ todo>> ] [ max-depth>> ] bi
            '[
                _ <= spider get
                [ count>> ] [ max-count>> ] bi < and
            ] [ spider-page spider-sleep ] slurp-heap-when
            spider get
        ] with-variable
    ] with-logging ;
