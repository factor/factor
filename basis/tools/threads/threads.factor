! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs io io.styles kernel math.order
math.parser prettyprint sequences sorting system threads ;
IN: tools.threads

: thread. ( thread -- )
    dup id>> pprint-cell
    dup name>> [
        over write-object
    ] with-cell
    dup state>> [
        [ dup self eq? "running" "yield" ? ] unless*
        write
    ] with-cell
    [
        sleep-entry>> [
            key>> nano-count [-] number>string write
            " nanos" write
        ] when*
    ] with-cell ;

: threads. ( -- )
    standard-table-style [
        [
            { "ID:" "Name:" "Waiting on:" "Remaining sleep:" }
            [ [ write ] with-cell ] each
        ] with-row

        threads sort-keys values [
            [ thread. ] with-row
        ] each
    ] tabular-output nl ;
