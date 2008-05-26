USING: math kernel accessors html.components
http.server http.server.actions
http.server.sessions html.templates.chloe fry ;
IN: webapps.counter

SYMBOL: count

TUPLE: counter-app < dispatcher ;

M: counter-app init-session* drop 0 count sset ;

: <counter-action> ( quot -- action )
    <action>
        swap '[ count , schange "" f <standard-redirect> ] >>submit ;

: counter-template ( -- template )
    "resource:extra/webapps/counter/counter.xml" <chloe> ;

: <display-action> ( -- action )
    <page-action>
        [ count sget "counter" set-value ] >>init
        counter-template >>template ;

: <counter-app> ( -- responder )
    counter-app new-dispatcher
        [ 1+ ] <counter-action> "inc" add-responder
        [ 1- ] <counter-action> "dec" add-responder
        <display-action> "" add-responder
    <sessions> ;
