! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit fry kernel macros math.order
sequences words sorting sequences.deep assocs splitting.monotonic
math ;
IN: sorting.slots

<PRIVATE

: short-circuit-comparator ( obj1 obj2 word -- comparator/? )
    execute( obj1 obj2 -- obj3 )
    dup +eq+ eq? [ drop f ] when ;

: slot-comparator ( seq -- quot )
    unclip-last-slice [
        [
            '[ [ _ execute( tuple -- value ) ] bi@ ]
        ] map concat
    ] [
        '[ _ call( obj1 obj2 -- obj3 obj4 ) _ short-circuit-comparator ]
    ] bi* ;

PRIVATE>

MACRO: compare-slots ( sort-specs -- quot )
    #! sort-spec: { accessors comparator }
    [ slot-comparator ] map '[ _ 2|| +eq+ or ] ;

: sort-by-slots ( seq sort-specs -- seq' )
    '[ _ compare-slots ] sort ;

MACRO: compare-seq ( seq -- quot )
    [ '[ _ short-circuit-comparator ] ] map '[ _ 2|| +eq+ or ] ;

: sort-by ( seq sort-seq -- seq' )
    '[ _ compare-seq ] sort ;

: sort-keys-by ( seq sort-seq -- seq' )
    '[ [ first ] bi@ _ compare-seq ] sort ;

: sort-values-by ( seq sort-seq -- seq' )
    '[ [ second ] bi@ _ compare-seq ] sort ;

MACRO: split-by-slots ( accessor-seqs -- quot )
    [ [ '[ [ _ execute( tuple -- value ) ] bi@ ] ] map concat
    [ = ] compose ] map
    '[ [ _ 2&& ] slice monotonic-slice ] ;
