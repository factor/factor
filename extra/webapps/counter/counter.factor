USING: math kernel accessors http.server http.server.dispatchers
furnace furnace.actions furnace.sessions
html.components html.templates.chloe
fry urls ;
IN: webapps.counter

SYMBOL: count

TUPLE: counter-app < dispatcher ;

M: counter-app init-session* drop 0 count sset ;

: <counter-action> ( quot -- action )
    <action>
        swap '[
            count , schange
            URL" $counter-app" <redirect>
        ] >>submit ;

: <display-action> ( -- action )
    <page-action>
        [ count sget "counter" set-value ] >>init
        { counter-app "counter" } >>template ;

: <counter-app> ( -- responder )
    counter-app new-dispatcher
        [ 1+ ] <counter-action> "inc" add-responder
        [ 1- ] <counter-action> "dec" add-responder
        <display-action> "" add-responder
    <sessions> ;
