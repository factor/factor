! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences regexp.transition-tables fry assocs
accessors locals math sorting arrays sets hashtables regexp.dfa
combinators.short-circuit ;
IN: regexp.minimize

: number-transitions ( transitions numbering -- new-transitions )
    dup '[
        [ _ at ]
        [ [ first _ at ] assoc-map ] bi*
    ] assoc-map ;

: table>state-numbers ( table -- assoc )
    transitions>> keys <enum> [ swap ] H{ } assoc-map-as ;

: map-set ( assoc quot -- new-assoc )
    '[ drop @ dup ] assoc-map ; inline

: rewrite-transitions ( transition-table assoc quot -- transition-table )
    [
        [ clone ] dip
        [ '[ _ at ] change-start-state ]
        [ '[ [ _ at ] map-set ] change-final-states ]
        [ ] tri
    ] dip '[ _ @ ] change-transitions ; inline

: number-states ( table -- newtable )
    dup table>state-numbers
    [ number-transitions ] rewrite-transitions ;

: initially-same? ( s1 s2 transition-table -- ? )
    {
        [ drop <= ]
        [ transitions>> '[ _ at keys ] bi@ set= ]
        [ final-states>> '[ _ key? ] bi@ = ]
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
    clone number-states combine-states ;
