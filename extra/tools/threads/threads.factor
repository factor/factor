! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools.threads
USING: threads kernel prettyprint prettyprint.config
io io.styles sequences assocs namespaces sorting boxes ;

: thread. ( thread -- )
    dup thread-id pprint-cell
    dup thread-name pprint-cell
    thread-state "running" or
    [ write ] with-cell ;

: threads. ( -- )
    standard-table-style [
        [
            { "ID" "Name" "Waiting on" }
            [ [ write ] with-cell ] each
        ] with-row

        threads >alist sort-keys values [
            [ thread. ] with-row
        ] each
    ] tabular-output ;
