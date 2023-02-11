! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
hash-sets kernel math regexp.classes regexp.transition-tables
sequences sets sorting ;
IN: regexp.minimize

: table>state-numbers ( table -- assoc )
    transitions>> keys H{ } zip-index-as ;

: number-states ( table -- newtable )
    dup table>state-numbers transitions-at ;

: has-conditions? ( assoc -- ? )
    values [ condition? ] any? ;

: initially-same? ( s1 s2 transition-table -- ? )
    {
        [ drop <= ]
        [ final-states>> '[ _ in? ] bi@ = ]
        [ transitions>> '[ _ at keys ] bi@ set= ]
    } 3&& ;

:: initialize-partitions ( transition-table -- partitions )
    ! Partition table is sorted-array => ?
    transition-table transitions>> keys sort :> states
    states length 2/ sq <hash-set> :> out
    states [| s1 i1 |
        states [| s2 |
            s1 s2 transition-table initially-same?
            [ s1 s2 2array out adjoin ] when
        ] i1 each-from
    ] each-index out ;

: same-partition? ( s1 s2 partitions -- ? )
    { [ [ sort-pair 2array ] dip in? ] [ drop = ] } 3|| ;

: stay-same? ( s1 s2 transition partitions -- ? )
    [ '[ _ transitions>> at ] bi@ ] dip
    '[ [ at ] dip _ same-partition? ] with assoc-all? ;

:: partition-more ( partitions transition-table -- partitions changed? )
    partitions cardinality :> size
    partitions members [
        dup first2 transition-table partitions stay-same?
        [ drop ] [ partitions delete ] if
    ] each partitions dup cardinality size = not ;

: partition>classes ( partitions -- synonyms ) ! old-state => new-state
    members inv-sort [ swap ] H{ } assoc-map-as ;

: (state-classes) ( transition-table -- partition )
    [ initialize-partitions ] keep '[ _ partition-more ] loop ;

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
