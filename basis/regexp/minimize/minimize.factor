! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences regexp.transition-tables fry assocs
accessors locals math sorting arrays sets hashtables regexp.dfa  ;
IN: regexp.minimize

:: initialize-partitions ( transition-table -- partitions )
    ! Partition table is sorted-array => ?
    H{ } clone :> out
    transition-table transitions>> keys :> states
    states [| s1 |
        states [| s2 |
            s1 s2 <= [
                s1 s2 [ transition-table transitions>> at keys ] bi@ set=
                s1 s2 [ transition-table final-states>> key? ] bi@ = and
                [ t s1 s2 2array out set-at ] when
            ] when
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
    ! This is horribly slow!
    over '[ drop first2 _ _ stay-same? ] assoc-filter ;

: partition>classes ( partitions -- synonyms ) ! old-state => new-state
    >alist sort-keys
    [ drop first2 swap ] assoc-map
    <reversed>
    >hashtable ;

: state-classes ( transition-table -- synonyms )
    [ initialize-partitions ] keep
    '[ _ partition-more ] [ ] while-changes
    partition>classes ;

: canonical-state? ( state state-classes -- ? )
    dupd at = ;

: delete-duplicates ( transitions state-classes -- new-transitions )
    '[ drop _ canonical-state? ] assoc-filter ;

: rewrite-duplicates ( new-transitions state-classes -- new-transitions )
    '[ [ _ at ] assoc-map ] assoc-map ;

: map-set ( assoc quot -- new-assoc )
    '[ drop @ dup ] assoc-map ; inline

: combine-states ( table -- smaller-table )
    dup state-classes
    [
        '[
            _ [ delete-duplicates ]
            [ rewrite-duplicates ] bi
        ] change-transitions
    ]
    [ '[ [ _ at ] map-set ] change-final-states ]
    [ '[ _ at ] change-start-state ]
    tri ;

: number-transitions ( transitions numbering -- new-transitions )
    [
        [ at ]
        [ '[ first _ at ] assoc-map ]
        bi-curry bi*
    ] curry assoc-map ;

: number-states ( table -- newtable )
    dup transitions>> keys <enum> [ swap ] H{ } assoc-map-as
    [ '[ _ at ] change-start-state ]
    [ '[ [ _ at ] map-set ] change-final-states ]
    [ '[ _ number-transitions ] change-transitions ] tri ;

: minimize ( table -- minimal-table )
    clone number-states combine-states ;
