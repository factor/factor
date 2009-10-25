! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays generic assocs io math
namespaces parser prettyprint strings io.styles words
system sorting splitting grouping math.parser classes memory
combinators fry ;
IN: tools.memory

<PRIVATE

: kilobytes ( n -- str )
    number>string
    dup length 4 > [ 3 cut* "," glue ] when
    " KB" append ;

: memory-table. ( sizes seq -- )
    swap [ kilobytes ] map zip simple-table. ;

: young-room. ( seq -- )
    { "Total:" "Allocated:" "Free:" } memory-table. ;

: nursery-room. ( seq -- ) "- Nursery space" print young-room. ;

: aging-room. ( seq -- ) "- Aging space" print young-room. ;

: mark-sweep-table. ( sizes -- )
    { "Total:" "Allocated:" "Contiguous free:" "Total free:" } memory-table. ;

: tenured-room. ( seq -- ) "- Tenured space" print mark-sweep-table. ;

: misc-room. ( seq -- )
    "- Miscellaneous buffers" print
    { "Card array:" "Deck array:" "Mark stack:" } memory-table. ;

: data-room. ( -- )
    "==== DATA HEAP" print nl
    data-room
    3 cut [ nursery-room. nl ] dip
    3 cut [ aging-room. nl ] dip
    4 cut [ tenured-room. nl ] dip
    misc-room. ;

: code-room. ( -- )
    "==== CODE HEAP" print nl
    code-room mark-sweep-table. ;

: heap-stat-step ( obj counts sizes -- )
    [ [ class ] dip inc-at ]
    [ [ [ size ] [ class ] bi ] dip at+ ] bi-curry* bi ;

PRIVATE>

: room. ( -- ) data-room. nl code-room. ;

: heap-stats ( -- counts sizes )
    [ ] instances H{ } clone H{ } clone
    [ '[ _ _ heap-stat-step ] each ] 2keep ;

: heap-stats. ( -- )
    heap-stats dup keys natural-sort standard-table-style [
        [ { "Class" "Bytes" "Instances" } [ write-cell ] each ] with-row
        [
            [
                dup pprint-cell
                dup pick at pprint-cell
                pick at pprint-cell
            ] with-row
        ] each 2drop
    ] tabular-output nl ;
