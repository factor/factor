! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db.sqlite furnace.actions furnace.alloy
furnace.conversations furnace.recaptcha furnace.redirection
html.templates.chloe.compiler http.server
http.server.dispatchers http.server.responses io.streams.string
kernel urls xml.syntax ;
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
        "6LeJWQgAAAAAAFlYV7SuBClE9uSpGtV_ZS-qVON7" >>public-key
        "6LeJWQgAAAAAALh-XJgSSQ6xKygRgJ8-029Ip2Xv" >>private-key ;

: <recaptcha-app> ( -- obj )
    \ recaptcha-app new-dispatcher
        <recaptcha-challenge> "" add-responder
        <test-recaptcha>
        recaptcha-db <alloy> ;
