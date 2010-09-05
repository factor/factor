! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server.responses
mason.server math.parser ;
IN: webapps.mason.counter

: <counter-action> ( -- action )
    <action>
    [
        [
            counter-value number>string
            "text/plain" <content>
        ] with-mason-db
    ] >>display ;
