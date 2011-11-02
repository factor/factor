! (c)2011 Joe Groff bsd license
USING: accessors assocs calendar combinators
combinators.short-circuit continuations fry generalizations
hashtables.identity io kernel kernel.private locals math
math.statistics math.vectors memory namespaces prettyprint
sequences sequences.generalizations sets sorting
tools.profiler.sampling.private ;
FROM: sequences => change-nth ;
FROM: assocs => change-at ;
IN: tools.profiler.sampling

SYMBOL: raw-profile-data
SYMBOL: samples-per-second

samples-per-second [ 1,000 ] initialize

CONSTANT: ignore-words
    { signal-handler leaf-signal-handler profiling minor-gc }

: ignore-word? ( word -- ? ) ignore-words member? ; inline

: get-raw-profile-data ( -- data )
    raw-profile-data get-global [ "No profile data" throw ] unless* ;

: profile ( quot -- )
    samples-per-second get-global profiling
    [ 0 profiling ] [
        (get-samples) raw-profile-data set-global
    ] cleanup ; inline

: total-sample-count ( sample -- count ) 0 swap nth ;
: gc-sample-count ( sample -- count ) 1 swap nth ;
: jit-sample-count ( sample -- count ) 2 swap nth ;
: foreign-sample-count ( sample -- count ) 3 swap nth ;
: foreign-thread-sample-count ( sample -- count ) 4 swap nth ;
: sample-counts-slice ( sample -- counts ) 5 head-slice ;

: sample-thread ( sample -- alien ) 5 swap nth ;
: sample-callstack ( sample -- array ) 6 swap nth ;
: unclip-callstack ( sample -- sample' callstack-top )
    clone 6 over [ unclip swap ] change-nth ;

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

: collect-threads ( samples -- by-thread )
    [ sample-thread ] collect-by ;

: time-per-thread ( -- n )
    get-raw-profile-data collect-threads [ (total-time) ] assoc-map ;

: leaf-callstack? ( callstack -- ? )
    [ ignore-word? ] all? ;

CONSTANT: zero-counts { 0 0 0 0 0 }

: sum-counts ( samples -- times )
    zero-counts [ sample-counts-slice v+ ] reduce ;

TUPLE: profile-node
    total-time gc-time jit-time foreign-time foreign-thread-time children ;

: <profile-node> ( times children -- node )
    [ 5 firstn [ samples>time ] 5 napply ] dip profile-node boa ;

: <profile-root-node> ( samples collector-quot -- node )
    [ sum-counts ] swap bi <profile-node> ; inline

:: (collect-subtrees) ( samples child-quot -- children )
    samples [ sample-callstack leaf-callstack? not ] filter
    [ f ] [ child-quot call ] if-empty ; inline

: collect-tops ( samples -- node )
    [ unclip-callstack ] collect-pairs [
        [ sum-counts ]
        [ [ collect-tops ] (collect-subtrees) ] bi <profile-node>
    ] assoc-map ;

: redundant-root-node? ( assoc -- ? )
    {
        [ children>> assoc-size 1 = ]
        [ children>> values first children>> ]
        [ [ total-time>> ] [ children>> values first total-time>> ] bi = ]
    } 1&& ;

: trim-root ( root -- root' )
    dup redundant-root-node? [ children>> values first trim-root ] when ;

: (top-down) ( samples -- tree )
    collect-threads
    [ [ collect-tops ] <profile-root-node> trim-root ] assoc-map ;

: top-down ( -- tree )
    get-raw-profile-data (top-down) ;

:: collect-flat ( samples -- flat )
    IH{ } clone :> per-word-samples
    samples [| sample |
        sample sample-callstack unique keys [ ignore-word? not ] filter [
            per-word-samples [ zero-counts or sample sample-counts-slice v+ ] change-at
        ] each
    ] each
    per-word-samples [ f <profile-node> ] assoc-map ;

: redundant-flat-node? ( child-node root-node -- ? )
    [ total-time>> ] bi@ = ;

: trim-flat ( root-node -- root-node' )
    dup '[ [ nip _ redundant-flat-node? not ] assoc-filter ] change-children ;

: (flat) ( samples -- flat )
    collect-threads
    [ [ collect-flat ] <profile-root-node> trim-flat ] assoc-map ;

: flat ( -- tree )
    get-raw-profile-data (flat) ;

: depth. ( depth -- )
    [ "  " write ] times ;

: by-total-time ( nodes -- nodes' )
    >alist [ second total-time>> ] inv-sort-with ;

: duration. ( duration -- )
    samples-per-second get-global {
        { [ dup 1000 <= ] [ drop duration>milliseconds >integer pprint "ms" write ] }
        { [ dup 1,000,000 <= ] [ drop duration>microseconds >integer pprint "µs" write ] }
        [ drop duration>nanoseconds >integer pprint "ns" write ]
    } cond ;

DEFER: (profile.)

: times. ( node -- )
    {
        [ total-time>> duration. ]
        [ " (GC:" write gc-time>> duration. ]
        [ ", JIT:" write jit-time>> duration. ]
        [ ", FFI:" write foreign-time>> duration. ]
        [ ", FT:" write foreign-thread-time>> duration. ")" write ]
    } cleave ;

:: (profile-node.) ( word node depth -- )
    depth depth. node times. ": " write word pprint-short nl
    node children>> depth 1 + (profile.) ;

: (profile.) ( nodes depth -- )
    [ by-total-time ] dip '[ _ (profile-node.) ] assoc-each ;

: profile. ( tree -- )
    [ 0 (profile-node.) ] assoc-each ;
