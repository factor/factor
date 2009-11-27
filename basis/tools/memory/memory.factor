! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.struct
combinators combinators.smart continuations fry generalizations
generic grouping io io.styles kernel make math math.parser
math.statistics memory namespaces parser prettyprint sequences
sorting splitting strings system vm words ;
IN: tools.memory

<PRIVATE

: commas ( n -- str )
    dup 0 < [ neg commas "-" prepend ] [
        number>string
        reverse 3 group "," join reverse
    ] if ;

: kilobytes ( n -- str )
    1024 /i commas " KB" append ;

: nanos>string ( n -- str )
    1000 /i commas " µs" append ;

: copying-room. ( copying-sizes -- )
    {
        { "Size:" [ size>> kilobytes ] }
        { "Occupied:" [ occupied>> kilobytes ] }
        { "Free:" [ free>> kilobytes ] }
    } object-table. ;

: nursery-room. ( data-room -- )
    "- Nursery space" print nursery>> copying-room. ;

: aging-room. ( data-room -- )
    "- Aging space" print aging>> copying-room. ;

: mark-sweep-table. ( mark-sweep-sizes -- )
    {
        { "Size:" [ size>> kilobytes ] }
        { "Occupied:" [ occupied>> kilobytes ] }
        { "Total free:" [ total-free>> kilobytes ] }
        { "Contiguous free:" [ contiguous-free>> kilobytes ] }
        { "Free block count:" [ free-block-count>> number>string ] }
    } object-table. ;

: tenured-room. ( data-room -- )
    "- Tenured space" print tenured>> mark-sweep-table. ;

: misc-room. ( data-room -- )
    "- Miscellaneous buffers" print
    {
        { "Card array:" [ cards>> kilobytes ] }
        { "Deck array:" [ decks>> kilobytes ] }
        { "Mark stack:" [ mark-stack>> kilobytes ] }
    } object-table. ;

: data-room. ( -- )
    "== Data heap ==" print nl
    data-room data-heap-room memory>struct {
        [ nursery-room. nl ]
        [ aging-room. nl ]
        [ tenured-room. nl ]
        [ misc-room. ]
    } cleave ;

: code-room. ( -- )
    "== Code heap ==" print nl
    code-room mark-sweep-sizes memory>struct mark-sweep-table. ;

PRIVATE>

: room. ( -- ) data-room. nl code-room. ;

<PRIVATE

: heap-stat-step ( obj counts sizes -- )
    [ [ class ] dip inc-at ]
    [ [ [ size ] [ class ] bi ] dip at+ ] bi-curry* bi ;

PRIVATE>

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

SYMBOL: gc-events

: collect-gc-events ( quot -- )
    enable-gc-events
    [ ] [ disable-gc-events drop ] cleanup
    disable-gc-events [ gc-event memory>struct ] map gc-events set ; inline

<PRIVATE

: gc-op-string ( op -- string )
    {
        { collect-nursery-op      [ "Copying from nursery" ] }
        { collect-aging-op        [ "Copying from aging"   ] }
        { collect-to-tenured-op   [ "Copying to tenured"   ] }
        { collect-full-op         [ "Mark and sweep"       ] }
        { collect-compact-op      [ "Mark and compact"     ] }
        { collect-growing-heap-op [ "Grow heap"            ] }
    } case ;

: (space-occupied) ( data-heap-room code-heap-room -- n )
    [
        [ [ nursery>> ] [ aging>> ] [ tenured>> ] tri [ occupied>> ] tri@ ]
        [ occupied>> ]
        bi*
    ] sum-outputs ;

: space-occupied-before ( event -- bytes )
    [ data-heap-before>> ] [ code-heap-before>> ] bi (space-occupied) ;

: space-occupied-after ( event -- bytes )
    [ data-heap-after>> ] [ code-heap-after>> ] bi (space-occupied) ;

: space-reclaimed ( event -- bytes )
    [ space-occupied-before ] [ space-occupied-after ] bi - ;

TUPLE: gc-stats collections times ;

: <gc-stats> ( -- stats )
    gc-stats new
        0 >>collections
        V{ } clone >>times ; inline

: compute-gc-stats ( events -- stats )
    V{ } clone [
        '[
            dup op>> _ [ drop <gc-stats> ] cache
            [ 1 + ] change-collections
            [ total-time>> ] dip times>> push
        ] each
    ] keep sort-keys ;

: gc-stats-table-row ( pair -- row )
    [
        [ first gc-op-string ] [
            second
            [ collections>> ]
            [
                times>> {
                    [ sum nanos>string ]
                    [ mean >integer nanos>string ]
                    [ median >integer nanos>string ]
                    [ infimum nanos>string ]
                    [ supremum nanos>string ]
                } cleave
            ] bi
        ] bi
    ] output>array ;

: gc-stats-table ( stats -- table )
    [ gc-stats-table-row ] map
    { "" "Number" "Total" "Mean" "Median" "Min" "Max" } prefix ;

PRIVATE>

: gc-event. ( event -- )
    {
        { "Event type:" [ op>> gc-op-string ] }
        { "Total time:" [ total-time>> nanos>string ] }
        { "Space reclaimed:" [ space-reclaimed kilobytes ] }
    } object-table. ;

: gc-events. ( -- )
    gc-events get [ gc-event. nl ] each ;

: gc-stats. ( -- )
    gc-events get compute-gc-stats gc-stats-table simple-table. ;

: gc-summary. ( -- )
    gc-events get {
        { "Collections:" [ length commas ] }
        { "Cards scanned:" [ [ cards-scanned>> ] map-sum commas ] }
        { "Decks scanned:" [ [ decks-scanned>> ] map-sum commas ] }
        { "Code blocks scanned:" [ [ code-blocks-scanned>> ] map-sum commas ] }
        { "Total time:" [ [ total-time>> ] map-sum nanos>string ] }
        { "Card scan time:" [ [ card-scan-time>> ] map-sum nanos>string ] }
        { "Code block scan time:" [ [ code-scan-time>> ] map-sum nanos>string ] }
        { "Data heap sweep time:" [ [ data-sweep-time>> ] map-sum nanos>string ] }
        { "Code heap sweep time:" [ [ code-sweep-time>> ] map-sum nanos>string ] }
        { "Compaction time:" [ [ compaction-time>> ] map-sum nanos>string ] }
    } object-table. ;
