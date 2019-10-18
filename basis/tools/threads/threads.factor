! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads kernel prettyprint prettyprint.config
io io.styles sequences assocs namespaces sorting boxes
heaps.private system math math.parser math.order accessors ;
IN: tools.threads

: thread. ( thread -- )
    dup id>> pprint-cell
    dup name>> over [ write-object ] with-cell
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

        threads >alist sort-keys values [
            [ thread. ] with-row
        ] each
    ] tabular-output nl ;
