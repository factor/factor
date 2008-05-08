! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting locals math math.order
calendar alarms logging concurrency.combinators namespaces
sequences.lib db.types db.tuples db fry
rss xml.writer
http.server
http.server.crud
http.server.forms
http.server.actions
http.server.boilerplate
http.server.templating.chloe
http.server.components
http.server.auth.login
http.server.auth ;
IN: webapps.planet

TUPLE: planet-factor < dispatcher postings ;

: planet-template ( name -- template )
    "resource:extra/webapps/planet/" swap ".xml" 3append <chloe> ;

TUPLE: blog id name www-url feed-url ;

M: blog link-title name>> ;

M: blog link-href www-url>> ;

blog "BLOGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "name" "NAME" { VARCHAR 256 } +not-null+ }
    { "www-url" "WWWURL" { VARCHAR 256 } +not-null+ }
    { "feed-url" "FEEDURL" { VARCHAR 256 } +not-null+ }
} define-persistent

: init-blog-table blog ensure-table ;

: <blog> ( id -- todo )
    blog new
        swap >>id ;

: blogroll ( -- seq )
    f <blog> select-tuples [ [ name>> ] compare ] sort ;

: <entry-form> ( -- form )
    "entry" <form>
        "entry" planet-template >>view-template
        "entry-summary" planet-template >>summary-template
        "title" <string> add-field
        "description" <html-text> add-field
        "pub-date" <date> add-field ;

: <blog-form> ( -- form )
    "blog" <form>
        "edit-blog" planet-template >>edit-template
        "blog-admin-link" planet-template >>summary-template
        "id" <integer>
            hidden >>renderer
            add-field
        "name" <string>
            t >>required
            add-field
        "www-url" <url>
            t >>required
            add-field
        "feed-url" <url>
            t >>required
            add-field ;

: <planet-factor-form> ( -- form )
    "planet-factor" <form>
        "postings" planet-template >>view-template
        "postings-summary" planet-template >>summary-template
        "postings" <entry-form> +plain+ <list> add-field
        "blogroll" "blog" <link> +unordered+ <list> add-field ;

: <admin-form> ( -- form )
    "admin" <form>
        "admin" planet-template >>view-template
        "blogroll" <blog-form> +unordered+ <list> add-field ;

:: <edit-blogroll-action> ( planet -- action )
    [let | form [ <admin-form> ] |
        <action>
            [
                blank-values

                blogroll "blogroll" set-value

                form view-form
            ] >>display
    ] ;

:: <planet-action> ( planet -- action )
    [let | form [ <planet-factor-form> ] |
        <action>
            [
                blank-values

                planet postings>> "postings" set-value
                blogroll "blogroll" set-value

                form view-form
            ] >>display
    ] ;

:: planet-feed ( planet -- feed )
    feed new
        "Planet Factor" >>title
        "http://planet.factorcode.org" >>link
        planet postings>> 16 short head >>entries ;

:: <feed-action> ( planet -- action )
    <action>
        [
            "text/xml" <content>
            [ planet planet-feed feed>xml write-xml ] >>body
        ] >>display ;

: <posting> ( name entry -- entry' )
    clone [ ": " swap 3append ] change-title ;

: fetch-feed ( url -- feed )
    download-feed entries>> ;

\ fetch-feed DEBUG add-error-logging

: fetch-blogroll ( blogroll -- entries )
    dup
    [ feed-url>> fetch-feed ] parallel-map
    [ >r name>> r> [ <posting> ] with map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ pub-date>> ] compare ] sort <reversed> ;

: update-cached-postings ( planet -- )
    "webapps.planet" [
        blogroll fetch-blogroll sort-entries 8 short head
        >>postings drop
    ] with-logging ;

:: <update-action> ( planet -- action )
    <action>
        [
            planet update-cached-postings
            "" f <temporary-redirect>
        ] >>display ;

:: <planet-factor-admin> ( planet-factor -- responder )
    [let | blog-form [ <blog-form> ]
           blog-ctor [ [ <blog> ] ] |
        <dispatcher>
            planet-factor <edit-blogroll-action> >>default

            planet-factor <update-action> "update" add-responder

            ! Administrative CRUD
                      blog-ctor "$planet-factor/admin"          <delete-action> "delete-blog" add-responder
            blog-form blog-ctor "$planet-factor/admin" <edit-action>   "edit-blog"   add-responder
    ] ;

SYMBOL: can-administer-planet-factor?

can-administer-planet-factor? define-capability

: <planet-factor> ( -- responder )
    planet-factor new-dispatcher
        dup <planet-action> "list" add-main-responder
        dup <feed-action> "feed.xml" add-responder
        dup <planet-factor-admin> { can-administer-planet-factor? } <protected> "admin" add-responder
    <boilerplate>
        "planet" planet-template >>template ;

: start-update-task ( planet db seq -- )
    '[
        , , , [
            dup filter-responder? [ responder>> ] when
            update-cached-postings
        ] with-db
    ] 10 minutes every drop ;
