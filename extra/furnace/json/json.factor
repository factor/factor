! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: json.writer http.server.responses ;
IN: furnace.json

: <json-content> ( body -- response )
    >json "application/json" <content> ;
