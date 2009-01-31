! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit fry kernel macros math.order
sequences words sorting sequences.deep assocs splitting.monotonic
math ;
IN: sorting.slots

<PRIVATE

: slot-comparator ( seq -- quot )
    [
        but-last-slice
        [ '[ [ _ execute ] bi@ ] ] map concat
    ] [
        peek
        '[ @ _ execute dup +eq+ eq? [ drop f ] when ]
    ] bi ;

PRIVATE>

MACRO: compare-slots ( sort-specs -- <=> )
    #! sort-spec: { accessors comparator }
    [ slot-comparator ] map '[ _ 2|| +eq+ or ] ;

: sort-by-slots ( seq sort-specs -- seq' )
    '[ _ compare-slots ] sort ;

MACRO: split-by-slots ( accessor-seqs -- quot )
    [ [ '[ [ _ execute ] bi@ ] ] map concat [ = ] compose ] map
    '[ [ _ 2&& ] slice monotonic-slice ] ;
