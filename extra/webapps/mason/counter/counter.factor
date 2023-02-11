! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server.responses
webapps.mason.backend math.parser ;
IN: webapps.mason.counter

: <counter-action> ( -- action )
    <action>
    [
        [
            counter-value number>string
            <text-content>
        ] with-mason-db
    ] >>display ;
