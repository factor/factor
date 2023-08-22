! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions math.parser
http.server.responses webapps.mason.backend ;
IN: webapps.mason.increment-counter

: <increment-counter-action> ( -- action )
    <action>
    [
        [
            increment-counter-value
            number>string <text-content>
        ] with-mason-db
    ] >>submit ;
