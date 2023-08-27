! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db.sqlite furnace.actions furnace.alloy
furnace.recaptcha furnace.redirection http.server.dispatchers
urls ;
IN: furnace.recaptcha.example

TUPLE: recaptcha-app < dispatcher recaptcha ;

: recaptcha-db ( -- obj ) "resource:recaptcha-example" <sqlite-db> ;

: <recaptcha-challenge> ( -- obj )
    <page-action>
        [ validate-recaptcha ] >>validate
        [ "?good" >url <redirect> ] >>submit
        { recaptcha-app "example" } >>template ;

: <test-recaptcha> ( responder -- recaptcha )
    <recaptcha>
        "concatenative.org" >>domain
        "6LeJWQgAAAAAAFlYV7SuBClE9uSpGtV_ZS-qVON7" >>site-key
        "6LeJWQgAAAAAALh-XJgSSQ6xKygRgJ8-029Ip2Xv" >>secret-key ;

: <recaptcha-app> ( -- obj )
    \ recaptcha-app new-dispatcher
        <recaptcha-challenge> "" add-responder
        <test-recaptcha>
        recaptcha-db <alloy> ;
