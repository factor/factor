! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit fry kernel macros math.order
sequences words sorting ;
IN: sorting.slots

<PRIVATE

: slot-comparator ( accessor comparator -- quot )
    '[ [ _ execute ] bi@ _ execute dup +eq+ eq? [ drop f ] when ] ;

PRIVATE>

MACRO: compare-slots ( sort-specs -- <=> )
    #! sort-spec: { accessor comparator }
    [ first2 slot-comparator ] map '[ _ 2|| +eq+ or ] ;

: sort-by-slots ( seq sort-specs -- seq' )
    '[ _ compare-slots ] sort ;
