! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads kernel prettyprint prettyprint.config
io io.styles sequences assocs namespaces sorting boxes
heaps.private system math math.parser math.order ;
IN: tools.threads

: thread. ( thread -- )
    dup thread-id pprint-cell
    dup thread-name over [ write-object ] with-cell
    dup thread-state [
        [ dup self eq? "running" "yield" ? ] unless*
        write
    ] with-cell
    [
        thread-sleep-entry [
            entry-key millis [-] number>string write
            " ms" write
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
    ] tabular-output ;
