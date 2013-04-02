! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences regexp.transition-tables fry assocs
accessors locals math sorting arrays sets hashtables regexp.dfa
combinators.short-circuit regexp.classes ;
FROM: assocs => change-at ;
IN: regexp.minimize

: table>state-numbers ( table -- assoc )
    transitions>> keys <enum> [ swap ] H{ } assoc-map-as ;

: number-states ( table -- newtable )
    dup table>state-numbers transitions-at ;

: has-conditions? ( assoc -- ? )
    values [ condition? ] any? ;

: initially-same? ( s1 s2 transition-table -- ? )
    {
        [ drop <= ]
        [ transitions>> '[ _ at keys ] bi@ set= ]
        [ final-states>> '[ _ in? ] bi@ = ]
    } 3&& ;

:: initialize-partitions ( transition-table -- partitions )
    ! Partition table is sorted-array => ?
    H{ } clone :> out
    transition-table transitions>> keys :> states
    states [| s1 |
        states [| s2 |
            s1 s2 transition-table initially-same?
            [ s1 s2 2array out conjoin ] when
        ] each
    ] each out ;

: same-partition? ( s1 s2 partitions -- ? )
    { [ [ sort-pair 2array ] dip key? ] [ drop = ] } 3|| ;

: assemble-values ( assoc1 assoc2 -- values )
    dup keys '[ _ swap [ at ] curry map ] bi@ zip ;

: stay-same? ( s1 s2 transition partitions -- ? )
    [ '[ _ transitions>> at ] bi@ assemble-values ] dip
    '[ _ same-partition? ] assoc-all? ;

: partition-more ( partitions transition-table -- partitions )
    over '[ drop first2 _ _ stay-same? ] assoc-filter ;

: partition>classes ( partitions -- synonyms ) ! old-state => new-state
    sort-keys
    [ drop first2 swap ] assoc-map
    <reversed>
    >hashtable ;

:: (while-changes) ( ..a obj quot: ( ..a obj -- ..b obj' ) comp: ( ..b obj' -- ..a key ) old-key -- ..a obj )
    obj quot call :> new-obj
    new-obj comp call :> new-key
    new-key old-key =
    [ new-obj ]
    [ new-obj quot comp new-key (while-changes) ]
    if ; inline recursive

: while-changes ( obj quot pred -- obj' )
    3dup nip call (while-changes) ; inline

: (state-classes) ( transition-table -- partition )
    [ initialize-partitions ] keep
    '[ _ partition-more ] [ assoc-size ] while-changes ;

: assoc>set ( assoc -- keys-set )
    [ drop dup ] assoc-map ;

: state-classes ( transition-table -- synonyms )
    clone [ [ nip has-conditions? ] assoc-partition ] change-transitions
    [ assoc>set ] [ (state-classes) partition>classes ] bi* assoc-union ;

: canonical-state? ( state transitions state-classes -- ? )
    '[ dup _ at =  ] swap '[ _ at has-conditions? ] bi or ;

: delete-duplicates ( transitions state-classes -- new-transitions )
    dupd '[ drop _ _ canonical-state? ] assoc-filter ;

: combine-states ( table -- smaller-table )
    dup state-classes
    [ transitions-at ] keep
    '[ _ delete-duplicates ] change-transitions ;

: combine-state-transitions ( hash -- hash )
    [ H{ } clone ] dip over '[
        _ [ 2array <or-class> ] change-at
    ] assoc-each [ swap ] assoc-map ;

: combine-transitions ( table -- table )
    [ [ combine-state-transitions ] assoc-map ] change-transitions ;

: minimize ( table -- minimal-table )
    clone
    number-states
    combine-states
    combine-transitions
    expand-ors ;
