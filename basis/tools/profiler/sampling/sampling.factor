! (c)2011 Joe Groff bsd license
USING: accessors assocs combinators
combinators.short-circuit continuations fry generalizations
hashtables.identity io kernel kernel.private layouts locals
math math.parser math.parser.private math.statistics
math.vectors memory namespaces prettyprint sequences
sequences.generalizations sets sorting ;
FROM: sequences => change-nth ;
FROM: assocs => change-at ;
IN: tools.profiler.sampling

SYMBOL: samples-per-second

samples-per-second [ 1,000 ] initialize

<PRIVATE
SYMBOL: raw-profile-data
CONSTANT: ignore-words
    { signal-handler leaf-signal-handler profiling minor-gc }

: ignore-word? ( word -- ? ) ignore-words member? ; inline
PRIVATE>

: most-recent-profile-data ( -- profile-data )
    raw-profile-data get-global [ "No profile data" throw ] unless* ;

: profile ( quot -- )
    samples-per-second get-global profiling
    [ 0 profiling (get-samples) raw-profile-data set-global ]
    [ ] cleanup ; inline

: total-sample-count ( sample -- count ) 0 swap nth ;
: gc-sample-count ( sample -- count ) 1 swap nth ;
: jit-sample-count ( sample -- count ) 2 swap nth ;
: foreign-sample-count ( sample -- count ) 3 swap nth ;
: foreign-thread-sample-count ( sample -- count ) 4 swap nth ;
: sample-counts-slice ( sample -- counts ) 5 head-slice ;

: sample-thread ( sample -- thread ) 5 swap nth ;
: sample-callstack ( sample -- array ) 6 swap nth ;
: unclip-callstack ( sample -- sample' callstack-top )
    clone 6 over [ unclip swap ] change-nth ;

: samples>time ( samples -- seconds )
    samples-per-second get-global / ;

: total-time* ( profile-data -- n )
    [ total-sample-count ] map-sum samples>time ;

: gc-time* ( profile-data -- n )
    [ gc-sample-count ] map-sum samples>time ;

: foreign-time* ( profile-data -- n )
    [ foreign-sample-count ] map-sum samples>time ;

: foreign-thread-time* ( profile-data -- n )
    [ foreign-thread-sample-count ] map-sum samples>time ;

: total-time ( -- n )
    most-recent-profile-data total-time* ;
: gc-time ( -- n )
    most-recent-profile-data gc-time* ;
: foreign-time ( -- n )
    most-recent-profile-data foreign-time* ;
: foreign-thread-time ( -- n )
    most-recent-profile-data foreign-thread-time* ;

TUPLE: profile-node
    total-time gc-time jit-time foreign-time foreign-thread-time children
    depth ;

<PRIVATE

: collect-threads ( samples -- by-thread )
    [ sample-thread ] collect-by ;

: time-per-thread ( -- n )
    most-recent-profile-data collect-threads [ total-time* ] assoc-map ;

: leaf-callstack? ( callstack -- ? )
    [ ignore-word? ] all? ;

CONSTANT: zero-counts { 0 0 0 0 0 }

: sum-counts ( samples -- times )
    zero-counts [ sample-counts-slice v+ ] reduce ;

: <profile-node> ( times children depth -- node )
    [ 5 firstn [ samples>time ] 5 napply ] 2dip profile-node boa ;

: <profile-root-node> ( samples collector-quot -- node )
    [ sum-counts ] swap bi 0 <profile-node> ; inline

:: (collect-subtrees) ( samples max-depth depth child-quot: ( samples -- child ) -- children )
    max-depth depth > [
        samples [ sample-callstack leaf-callstack? not ] filter
        [ f ] [ child-quot call ] if-empty
    ] [ f ] if ; inline

:: collect-tops ( samples max-depth depth -- node )
    samples [ unclip-callstack ] collect-pairs [
        [ sum-counts ]
        [ max-depth depth [ max-depth depth 1 + collect-tops ] (collect-subtrees) ] bi
        depth <profile-node>
    ] assoc-map ;

: redundant-root-node? ( assoc -- ? )
    {
        [ children>> assoc-size 1 = ]
        [ children>> values first children>> ]
        [ [ total-time>> ] [ children>> values first total-time>> ] bi = ]
    } 1&& ;

: trim-root ( root -- root' )
    dup redundant-root-node? [ children>> values first trim-root ] when ;

:: (top-down) ( max-depth profile-data depth -- tree )
    profile-data collect-threads
    [ [ max-depth depth collect-tops ] <profile-root-node> trim-root ] assoc-map ;

PRIVATE>

: top-down-max-depth* ( max-depth profile-data -- tree )
    0 (top-down) ;

: top-down-max-depth ( max-depth -- tree )
    most-recent-profile-data top-down-max-depth* ;

: top-down* ( profile-data -- tree )
    most-positive-fixnum top-down-max-depth* ;

: top-down ( -- tree )
    most-positive-fixnum top-down-max-depth ;

<PRIVATE

:: counts+at ( key assoc sample -- )
    key assoc [ zero-counts or sample sample-counts-slice v+ ] change-at ;

:: collect-flat ( samples -- flat )
    IH{ } clone :> per-word-samples
    samples [| sample |
        sample sample-callstack unique keys [ ignore-word? not ] filter [
            per-word-samples sample counts+at
        ] each
    ] each
    per-word-samples [ f 0 <profile-node> ] assoc-map ;

: redundant-flat-node? ( child-node root-node -- ? )
    [ total-time>> ] same? ;

: trim-flat ( root-node -- root-node' )
    dup '[ [ nip _ redundant-flat-node? not ] assoc-filter ] change-children ;

PRIVATE>

: flat* ( profile-data -- flat )
    collect-threads
    [ [ collect-flat ] <profile-root-node> trim-flat ] assoc-map ;

: flat ( -- flat )
    most-recent-profile-data flat* ;

<PRIVATE

: nth-or-last ( n seq -- elt )
    [ drop f ] [
        2dup bounds-check? [ nth ] [ nip last ] if
    ] if-empty ;

:: collect-cross-section ( samples depth -- cross-section )
    IH{ } clone :> per-word-samples
    samples [| sample |
        depth sample sample-callstack [ ignore-word? ] trim-tail nth-or-last :> word
        word [
            word per-word-samples sample counts+at
        ] when
    ] each
    per-word-samples [ f depth <profile-node> ] assoc-map ;

PRIVATE>

:: cross-section* ( depth profile-data -- tree )
    profile-data collect-threads
    [ [ depth collect-cross-section ] <profile-root-node> ] assoc-map ;

: cross-section ( depth -- tree )
    most-recent-profile-data cross-section* ;

<PRIVATE

: depth. ( depth -- )
    [ "  " write ] times ;

: by-total-time ( nodes -- nodes' )
    >alist [ second total-time>> ] inv-sort-with ;

: duration. ( duration -- )
    1000 * >float "%9.1f" format-float write ;

: percentage. ( num denom -- )
    [ 100 * ] dip /f "%6.2f" format-float write ;

DEFER: (profile.)

:: times. ( node -- )
    node {
        [ depth>> number>string 4 CHAR: \s pad-head write " " write ]
        [ total-time>> duration. " " write ]
        [ [ gc-time>> ] [ total-time>> ] bi percentage. " " write ]
        [ [ jit-time>> ] [ total-time>> ] bi percentage. " " write ]
        [ [ foreign-time>> ] [ total-time>> ] bi percentage. " " write ]
        [ [ foreign-thread-time>> ] [ total-time>> ] bi percentage. " " write ]
    } cleave ;

:: (profile-node.) ( word node depth -- )
    node times.
    depth depth.
    word pprint-short nl
    node children>> depth 1 + (profile.) ;

: (profile.) ( nodes depth -- )
    [ by-total-time ] dip '[ _ (profile-node.) ] assoc-each ;

: profile-heading. ( -- )
    "depth   time ms  GC %  JIT %  FFI %   FT %" print ;
   ! NNNN XXXXXXX.X XXXX.X XXXX.X XXXX.X XXXX.X | | foo

PRIVATE>

: profile. ( tree -- )
    profile-heading.
    [ 0 (profile-node.) ] assoc-each ;
