! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools.threads
USING: concurrency.threads kernel prettyprint prettyprint.config
io io.styles sequences assocs namespaces sorting ;

: thread. ( thread -- )
    dup thread-id pprint-cell
    dup thread-name pprint-cell
    thread-continuation "Waiting" "Running" ? [ write ] with-cell ;

: threads. ( -- )
    standard-table-style [
        [
            { "ID" "Name" "State" }
            [ [ write ] with-cell ] each
        ] with-row

        threads get-global >alist sort-keys values [
            [ thread. ] with-row
        ] each
    ] tabular-output ;
