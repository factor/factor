! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit fry kernel macros math.order
sequences words sorting sequences.deep assocs splitting.monotonic
math ;
IN: sorting.slots

<PRIVATE

: short-circuit-comparator ( obj1 obj2 word --  comparator/? )
    execute dup +eq+ eq? [ drop f ] when ;

: slot-comparator ( seq -- quot )
    [
        but-last-slice
        [ '[ [ _ execute ] bi@ ] ] map concat
    ] [
        peek
        '[ @ _ short-circuit-comparator ]
    ] bi ;

PRIVATE>

MACRO: compare-slots ( sort-specs -- <=> )
    #! sort-spec: { accessors comparator }
    [ slot-comparator ] map '[ _ 2|| +eq+ or ] ;

: sort-by-slots ( seq sort-specs -- sortedseq )
    '[ _ compare-slots ] sort ;

MACRO: compare-seq ( seq -- quot )
    [ '[ _ short-circuit-comparator ] ] map '[ _ 2|| +eq+ or ] ;

: sort-by ( seq sort-seq -- sortedseq )
    '[ _ compare-seq ] sort ;

: sort-keys-by ( seq sort-seq -- sortedseq )
    '[ [ first ] bi@ _ compare-seq ] sort ;

: sort-values-by ( seq sort-seq -- sortedseq )
    '[ [ second ] bi@ _ compare-seq ] sort ;

MACRO: split-by-slots ( accessor-seqs -- quot )
    [ [ '[ [ _ execute ] bi@ ] ] map concat [ = ] compose ] map
    '[ [ _ 2&& ] slice monotonic-slice ] ;
