! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences vectors arrays generic assocs io math
namespaces parser prettyprint strings io.styles vectors words
system sorting splitting grouping math.parser classes memory
combinators ;
IN: tools.memory

<PRIVATE

: write-size ( n -- )
    number>string
    dup length 4 > [ 3 cut* "," swap 3append ] when
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
    data-room 2 <groups> dup length [
        [ first2 ] [ number>string "Generation " prepend ] bi*
        write-total/used/free
    ] 2each
    "Decks" write-total
    "Cards" write-total ;

: write-labelled-size ( n string -- )
    [ write-cell write-size ] with-row ;

: (code-room.) ( -- )
    code-room {
        [ "Size:" write-labelled-size ]
        [ "Used:" write-labelled-size ]
        [ "Total free space:" write-labelled-size ]
        [ "Largest free block:" write-labelled-size ]
    } spread ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap class rot at+ ] keep
    1 swap class rot at+ ;

PRIVATE>

: room. ( -- )
    "==== DATA HEAP" print
    standard-table-style [
        { "" "Total" "Used" "Free" } write-headings
        (data-room.)
    ] tabular-output
    nl
    "==== CODE HEAP" print
    standard-table-style [
        (code-room.)
    ] tabular-output ;

: heap-stats ( -- counts sizes )
    H{ } clone H{ } clone
    [ >r 2dup r> heap-stat-step ] each-object ;

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
    ] tabular-output ;
