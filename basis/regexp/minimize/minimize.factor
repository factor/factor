! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences regexp.transition-tables fry assocs
accessors locals math sorting arrays sets hashtables regexp.dfa
combinators.short-circuit regexp.classes ;
IN: regexp.minimize

: table>state-numbers ( table -- assoc )
    transitions>> keys <enum> [ swap ] H{ } assoc-map-as ;

: number-states ( table -- newtable )
    dup table>state-numbers transitions-at ;

: no-conditions? ( state transition-table -- ? )
    transitions>> at values [ condition? ] any? not ;

: initially-same? ( s1 s2 transition-table -- ? )
    {
        [ drop <= ]
        [ transitions>> '[ _ at keys ] bi@ set= ]
        [ final-states>> '[ _ key? ] bi@ = ]
    } 3&& ;

:: initialize-partitions ( transition-table -- partitions )
    ! Partition table is sorted-array => ?
    H{ } clone :> out
    transition-table transitions>> keys
    [ transition-table no-conditions? ] filter :> states
    states [| s1 |
        states [| s2 |
            s1 s2 transition-table initially-same?
            [ s1 s2 2array out conjoin ] when
        ] each
    ] each out ;

: same-partition? ( s1 s2 partitions -- ? )
    [ 2array natural-sort ] dip key? ;

: assemble-values ( assoc1 assoc2 -- values )
    dup keys '[ _ swap [ at ] curry map ] bi@ zip ;

: stay-same? ( s1 s2 transition partitions -- ? )
    [ '[ _ transitions>> at ] bi@ assemble-values ] dip
    '[ _ same-partition? ] assoc-all? ;

: partition-more ( partitions transition-table -- partitions )
    over '[ drop first2 _ _ stay-same? ] assoc-filter ;

: partition>classes ( partitions -- synonyms ) ! old-state => new-state
    >alist sort-keys
    [ drop first2 swap ] assoc-map
    <reversed>
    >hashtable ;

:: (while-changes) ( obj quot: ( obj -- obj' ) comp: ( obj -- key ) old-key -- obj )
    obj quot call :> new-obj
    new-obj comp call :> new-key
    new-key old-key =
    [ new-obj ]
    [ new-obj quot comp new-key (while-changes) ]
    if ; inline recursive

: while-changes ( obj quot pred -- obj' )
    3dup nip call (while-changes) ; inline

: state-classes ( transition-table -- synonyms )
    [ initialize-partitions ] keep
    '[ _ partition-more ] [ assoc-size ] while-changes
    partition>classes ;

: canonical-state? ( state state-classes -- ? )
    dupd at = ;

: delete-duplicates ( transitions state-classes -- new-transitions )
    '[ drop _ canonical-state? ] assoc-filter ;

: rewrite-duplicates ( new-transitions state-classes -- new-transitions )
    '[ [ _ at ] assoc-map ] assoc-map ;

: combine-transitions ( transitions state-classes -- new-transitions )
    [ delete-duplicates ] [ rewrite-duplicates ] bi ;

: combine-states ( table -- smaller-table )
    dup state-classes
    [ combine-transitions ] rewrite-transitions ;

: minimize ( table -- minimal-table )
    clone number-states ; ! combine-states ;
