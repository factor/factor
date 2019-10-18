! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences vectors arrays generic assocs io math
namespaces parser prettyprint strings io.styles vectors words
system sorting splitting math.parser classes memory ;
IN: tools.memory

: write-total/used/free ( free total str -- )
    [
        write-cell
        dup number>string write-cell
        over - number>string write-cell
        number>string write-cell
    ] with-row ;

: write-total ( n str -- )
    [
        write-cell
        number>string write-cell
        [ ] with-cell
        [ ] with-cell
    ] with-row ;

: write-headings ( seq -- )
    [ [ write-cell ] each ] with-row ;

: (data-room.) ( -- )
    data-room 2 <groups> 0 [
        "Generation " pick number>string append
        >r first2 r> write-total/used/free 1+
    ] reduce drop
    "Cards" write-total ;

: (code-room.) ( -- )
    code-room "Code space" write-total/used/free ;

: room. ( -- )
    standard-table-style [
        { "" "Total" "Used" "Free" } write-headings
        (data-room.)
        (code-room.)
    ] tabular-output ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap class rot at+ ] keep
    1 swap class rot at+ ;

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
