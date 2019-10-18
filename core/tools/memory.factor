! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: memory
USING: arrays errors generic assocs io kernel
kernel-internals math namespaces parser prettyprint sequences
strings styles vectors words ;

! Printing an overview of heap usage.

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
    ] reduce drop ;

: (code-room.) ( -- )
    code-room "Code space" write-total/used/free ;

: room. ( -- )
    H{ { table-gap { 10 0 } } } [
        { "" "Total" "Used" "Free" } write-headings
        (data-room.)
        "Semi-space" write-total
        "Cards" write-total
        (code-room.)
    ] tabular-output ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap class rot at+ ] keep
    1 swap class rot at+ ;

: heap-stats ( -- counts sizes )
    #! Return a list of instance count/total size pairs.
    H{ } clone H{ } clone
    [ >r 2dup r> heap-stat-step ] each-object ;

: heap-stats. ( -- )
    heap-stats dup keys natural-sort  H{ } [
        { "Class" "Bytes" "Instances" } write-headings
        [
            [
                dup pprint-cell
                dup pick at pprint-cell
                pick at pprint-cell
            ] with-row
        ] each 2drop
    ] tabular-output ;

: save ( -- ) image save-image ;
