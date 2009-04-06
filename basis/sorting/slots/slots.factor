! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit fry kernel macros math.order
sequences words sorting sequences.deep assocs splitting.monotonic
math ;
IN: sorting.slots

<PRIVATE

: short-circuit-comparator ( obj1 obj2 word --  comparator/? )
    execute dup +eq+ eq? [ drop f ] when ; inline

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

MACRO: sort-by-slots ( sort-specs -- quot )
    '[ [ _ compare-slots ] sort ] ;

MACRO: compare-seq ( seq -- quot )
    [ '[ _ short-circuit-comparator ] ] map '[ _ 2|| +eq+ or ] ;

MACRO: sort-by ( sort-seq -- quot )
    '[ [ _ compare-seq ] sort ] ;

MACRO: sort-keys-by ( sort-seq -- quot )
    '[ [ first ] bi@ _ compare-seq ] sort ;

MACRO: sort-values-by ( sort-seq -- quot )
    '[ [ second ] bi@ _ compare-seq ] sort ;

MACRO: split-by-slots ( accessor-seqs -- quot )
    [ [ '[ [ _ execute ] bi@ ] ] map concat [ = ] compose ] map
    '[ [ _ 2&& ] slice monotonic-slice ] ;
