! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays generic assocs io math
namespaces parser prettyprint strings io.styles words
system sorting splitting grouping math.parser classes memory
combinators fry vm specialized-arrays accessors continuations
classes.struct generalizations ;
SPECIALIZED-ARRAY: gc-event
IN: tools.memory

<PRIVATE

: kilobytes ( n -- str )
    1024 /i number>string
    dup length 4 > [ 3 cut* "," glue ] when
    " KB" append ;

: fancy-table. ( obj alist -- )
    [ [ nip first ] [ second call( obj -- str ) ] 2bi 2array ] with map
    simple-table. ;

: copying-room. ( copying-sizes -- )
    {
        { "Size:" [ size>> kilobytes ] }
        { "Occupied:" [ occupied>> kilobytes ] }
        { "Free:" [ free>> kilobytes ] }
    } fancy-table. ;

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
    } fancy-table. ;

: tenured-room. ( data-room -- )
    "- Tenured space" print tenured>> mark-sweep-table. ;

: misc-room. ( data-room -- )
    "- Miscellaneous buffers" print
    {
        { "Card array:" [ cards>> kilobytes ] }
        { "Deck array:" [ decks>> kilobytes ] }
        { "Mark stack:" [ mark-stack>> kilobytes ] }
    } fancy-table. ;

: data-room. ( -- )
    "==== DATA HEAP" print nl
    data-room data-heap-room memory>struct {
        [ nursery-room. nl ]
        [ aging-room. nl ]
        [ tenured-room. nl ]
        [ misc-room. ]
    } cleave ;

: code-room. ( -- )
    "==== CODE HEAP" print nl
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

: collect-gc-events ( quot -- events )
    enable-gc-events [ ] [ disable-gc-events drop ] cleanup
    disable-gc-events byte-array>gc-event-array ; inline

: generation-sizes-before ( events -- sizes )
    [
        {
            [ start-time>> ]
            [ nursery-size-before>> ]
            [ aging-size-before>> ]
            [ tenured-size-before>> ]
            [ code-size-before>> ]
        } cleave 5 narray
    ] { } map-as ;

: generation-sizes-after ( events -- sizes )
    [
        {
            [ start-time>> ]
            [ nursery-size-after>> ]
            [ aging-size-after>> ]
            [ tenured-size-after>> ]
            [ code-size-after>> ]
        } cleave 5 narray
    ] { } map-as ;

: reclaimed-space ( events -- sizes )
    [
        [ start-time>> ] [
            {
                [ [ nursery-size-before>> ] [ nursery-size-after>> ] bi - ]
                [ [   aging-size-before>> ] [   aging-size-after>> ] bi - ]
                [ [ tenured-size-before>> ] [ tenured-size-after>> ] bi - ]
                [ [    code-size-before>> ] [    code-size-after>> ] bi - ]
            } cleave
            + + +
        ] bi 2array
    ] { } map-as ;

: allocated-space ( events -- sizes )
    2 <sliced-clumps> [
        [ second start-time>> ] [
            {
                [ [ second nursery-size-before>> ] [ first nursery-size-after>> ] bi - ]
                [ [ second   aging-size-before>> ] [ first   aging-size-after>> ] bi - ]
                [ [ second tenured-size-before>> ] [ first tenured-size-after>> ] bi - ]
                [ [ second    code-size-before>> ] [ first    code-size-after>> ] bi - ]
            } cleave
            + + +
        ] bi 2array
    ] { } map-as ;
