! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays generic assocs io math
namespaces parser prettyprint strings io.styles words
system sorting splitting grouping math.parser classes memory
combinators fry ;
IN: tools.memory

<PRIVATE

: write-size ( n -- )
    number>string
    dup length 4 > [ 3 cut* "," glue ] when
    " KB" append write-cell ;

: write-total/used/free ( free total str -- )
    [
        write-cell
        dup write-size
        over - write-size
        write-size
    ] with-row ;

: write-total ( n str -- )
    [
        write-cell
        write-size
        [ ] with-cell
        [ ] with-cell
    ] with-row ;

: write-headings ( seq -- )
    [ [ write-cell ] each ] with-row ;

: (data-room.) ( -- )
    data-room 2 <groups> [
        [ first2 ] [ number>string "Generation " prepend ] bi*
        write-total/used/free
    ] each-index
    "Decks" write-total
    "Cards" write-total ;

: write-labeled-size ( n string -- )
    [ write-cell write-size ] with-row ;

: (code-room.) ( -- )
    code-room {
        [ "Size:" write-labeled-size ]
        [ "Used:" write-labeled-size ]
        [ "Total free space:" write-labeled-size ]
        [ "Largest free block:" write-labeled-size ]
    } spread ;

: heap-stat-step ( obj counts sizes -- )
    [ [ class ] dip inc-at ]
    [ [ [ size ] [ class ] bi ] dip at+ ] bi-curry* bi ;

PRIVATE>

: room. ( -- )
    "==== DATA HEAP" print
    standard-table-style [
        { "" "Total" "Used" "Free" } write-headings
        (data-room.)
    ] tabular-output
    nl nl
    "==== CODE HEAP" print
    standard-table-style [
        (code-room.)
    ] tabular-output
    nl ;

: heap-stats ( -- counts sizes )
    [ ] instances H{ } clone H{ } clone
    [ '[ _ _ heap-stat-step ] each ] 2keep ;

: heap-stats. ( -- )
    heap-stats dup keys natural-sort standard-table-style [
        { "Class" "Bytes" "Instances" } write-headings
        [
            [
                dup pprint-cell
                dup pick at pprint-cell
                pick at pprint-cell
            ] with-row
        ] each 2drop
    ] tabular-output nl ;
