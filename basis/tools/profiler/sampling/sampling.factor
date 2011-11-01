! (c)2011 Joe Groff bsd license
USING: assocs calendar continuations kernel math.statistics
math namespaces sequences tools.profiler.sampling.private ;
IN: tools.profiler.sampling

SYMBOL: raw-profile-data
SYMBOL: samples-per-second

CONSTANT: default-samples-per-second 1000

: get-raw-profile-data ( -- data )
    raw-profile-data get-global [ "No profile data" throw ] unless* ;

: profile* ( rate quot -- )
    [ [ samples-per-second set-global ] [ profiling ] bi ] dip
    [ 0 profiling ] [ ] cleanup
    (get-samples) raw-profile-data set-global ; inline

: profile ( quot -- ) default-samples-per-second swap profile* ; inline

: total-sample-count ( sample -- count ) first ;
: gc-sample-count ( sample -- count ) second ;
: foreign-sample-count ( sample -- count ) third ;
: foreign-thread-sample-count ( sample -- count ) fourth ;
: sample-context ( sample -- alien ) 4 swap nth ;
: sample-callstack ( sample -- array ) 5 swap nth ;

: samples>time ( samples -- time )
    samples-per-second get-global / seconds ;

: (total-time) ( samples -- n )
    [ total-sample-count ] map-sum samples>time ;

: (gc-time) ( samples -- n )
    [ gc-sample-count ] map-sum samples>time ;

: (foreign-time) ( samples -- n )
    [ foreign-sample-count ] map-sum samples>time ;

: (foreign-thread-time) ( samples -- n )
    [ foreign-thread-sample-count ] map-sum samples>time ;

: total-time ( -- n )
    get-raw-profile-data (total-time) ;
: gc-time ( -- n )
    get-raw-profile-data (gc-time) ;
: foreign-time ( -- n )
    get-raw-profile-data (foreign-time) ;
: foreign-thread-time ( -- n )
    get-raw-profile-data (foreign-thread-time) ;

: time-per-context ( -- n )
    get-raw-profile-data [ sample-context ] collect-by [ (total-time) ] assoc-map ;
