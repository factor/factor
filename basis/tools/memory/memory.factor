! Copyright (C) 2005, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs binary-search classes classes.struct
combinators combinators.smart continuations fry grouping hashtables
hints io io.styles kernel layouts literals math math.order math.parser
math.statistics memory namespaces prettyprint sequences
sequences.generalizations sorting vm ;
IN: tools.memory

<PRIVATE
PRIMITIVE: (callback-room) ( -- allocator-room )
PRIMITIVE: (code-blocks) ( -- array )
PRIMITIVE: (code-room) ( -- allocator-room )
PRIMITIVE: (data-room) ( -- data-room )
PRIMITIVE: disable-gc-events ( -- events )
PRIMITIVE: enable-gc-events ( -- )

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

PRIVATE>

: data-room ( -- data-heap-room )
    (data-room) data-heap-room memory>struct ;

: data-room. ( -- )
    "== Data heap ==" print nl
    data-room {
        [ nursery-room. nl ]
        [ aging-room. nl ]
        [ tenured-room. nl ]
        [ misc-room. ]
    } cleave ;

<PRIVATE

: heap-stat-step ( obj counts sizes -- )
    [ [ class-of ] dip inc-at ]
    [ [ [ size ] [ class-of ] bi ] dip at+ ] bi-curry* bi ;

PRIVATE>

: heap-stats ( -- counts sizes )
    [ ] instances H{ } clone H{ } clone
    [ '[ _ _ heap-stat-step ] each ] 2keep ;

: heap-stats. ( -- )
    heap-stats dup keys sort standard-table-style [
        [ { "Class" "Bytes" "Instances" } [ write-cell ] each ] with-row
        [
            [
                dup pprint-cell
                dup pick at pprint-cell
                pick at pprint-cell
            ] with-row
        ] each 2drop
    ] tabular-output nl ;

: collect-gc-events ( quot -- gc-events )
    enable-gc-events
    [ disable-gc-events ] [ drop ] cleanup
    [ gc-event memory>struct ] map ; inline

<PRIVATE

: gc-op-string ( op -- string )
    {
        { COLLECT-NURSERY-OP           [ "Copying from nursery" ] }
        { COLLECT-AGING-OP             [ "Copying from aging"   ] }
        { COLLECT-TO-TENURED-OP        [ "Copying to tenured"   ] }
        { COLLECT-FULL-OP              [ "Mark and sweep"       ] }
        { COLLECT-COMPACT-OP           [ "Mark and compact"     ] }
        { COLLECT-GROWING-DATA-HEAP-OP [ "Grow heap"            ] }
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
                    [ minimum nanos>string ]
                    [ maximum nanos>string ]
                } cleave
            ] bi
        ] bi
    ] output>array ;

: gc-stats-table ( stats -- table )
    [ gc-stats-table-row ] map
    { "" "Number" "Total" "Mean" "Median" "Min" "Max" } prefix ;

PRIVATE>

SYMBOL: gc-events

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

: sum-phase-times ( events phase -- n )
    '[ times>> _ swap nth ] map-sum nanos>string ; inline

: gc-summary. ( -- )
    gc-events get {
        { "Collections:" [ length commas ] }
        { "Cards scanned:" [ [ cards-scanned>> ] map-sum commas ] }
        { "Decks scanned:" [ [ decks-scanned>> ] map-sum commas ] }
        { "Code blocks scanned:" [ [ code-blocks-scanned>> ] map-sum commas ] }
        { "Total time:" [ [ total-time>> ] map-sum nanos>string ] }
        { "Card scan time:" [ PHASE-CARD-SCAN sum-phase-times ] }
        { "Code block scan time:" [ PHASE-CODE-SCAN sum-phase-times ] }
        { "Marking time:" [ PHASE-MARKING sum-phase-times ] }
        { "Data heap sweep time:" [ PHASE-DATA-SWEEP sum-phase-times ] }
        { "Code heap sweep time:" [ PHASE-CODE-SWEEP sum-phase-times ] }
        { "Data compaction time:" [ PHASE-DATA-COMPACTION sum-phase-times ] }
    } object-table. ;

TUPLE: code-block
    { owner read-only }
    { parameters read-only }
    { relocation read-only }
    { type read-only }
    { size read-only }
    { entry-point read-only } ;

TUPLE: code-blocks { blocks groups } { cache hashtable } ;

<PRIVATE

: <code-block> ( seq -- code-block )
    6 firstn-unsafe {
        [ ]
        [ ]
        [ ]
        [ ]
        [ ]
        [ tag-bits get shift ]
    } spread code-block boa ; inline

: <code-blocks> ( seq -- code-blocks )
    6 <groups> H{ } clone \ code-blocks boa ;

SYMBOL: code-heap-start
SYMBOL: code-heap-end

: in-code-heap? ( address -- ? )
    code-heap-start get code-heap-end get between? ;

: (lookup-return-address) ( addr seq -- code-block )
    [ entry-point>> <=> ] with search nip ;

HINTS: (lookup-return-address) code-blocks ;

PRIVATE>

M: code-blocks length blocks>> length ; inline

FROM: sequences.private => nth-unsafe ;

M: code-blocks nth-unsafe
    [ cache>> ] [ blocks>> ] bi
    '[ _ nth-unsafe <code-block> ] cache ; inline

INSTANCE: code-blocks immutable-sequence

: get-code-blocks ( -- blocks )
    (code-blocks) <code-blocks> ;

: with-code-blocks ( quot -- )
    [
        get-code-blocks
        [ \ code-blocks set ]
        [ first entry-point>> code-heap-start set ]
        [ last [ entry-point>> ] [ size>> ] bi + code-heap-end set ] tri
        call
    ] with-scope ; inline

: lookup-return-address ( addr -- code-block )
    dup in-code-heap?
    [ \ code-blocks get (lookup-return-address) ] [ drop f ] if ;

<PRIVATE

: code-block-stats ( code-blocks -- counts sizes )
    H{ } clone H{ } clone
    [ '[ [ size>> ] [ type>> ] bi [ nip _ inc-at ] [ _ at+ ] 2bi ] each ]
    2keep ;

: blocks ( n -- str ) number>string " blocks" append ;

: code-block-table-row ( string type counts sizes -- triple )
    [ at 0 or blocks ] [ at 0 or kilobytes ] bi-curry* bi 3array ;

: code-block-table. ( counts sizes -- )
    [
        {
            ${ "Optimized code:" CODE-BLOCK-OPTIMIZED }
            ${ "Unoptimized code:" CODE-BLOCK-UNOPTIMIZED }
            ${ "Inline caches:" CODE-BLOCK-PIC }
        }
    ] 2dip '[ _ _ code-block-table-row ] { } assoc>map
    simple-table. ;

PRIVATE>

: code-room ( -- mark-sweep-sizes )
    (code-room) mark-sweep-sizes memory>struct ;

: callback-room ( -- mark-sweep-sizes )
    (callback-room) mark-sweep-sizes memory>struct ;

: code-room. ( -- )
    "== Code heap ==" print nl
    code-room mark-sweep-table. nl
    get-code-blocks code-block-stats code-block-table. ;

: callback-room. ( -- )
    "== Callback heap ==" print nl
    callback-room mark-sweep-table. ;

: room. ( -- )
    data-room. nl code-room. nl callback-room. ;
