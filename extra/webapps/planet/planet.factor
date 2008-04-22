! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting locals math
calendar alarms logging concurrency.combinators
db.types db.tuples db
rss xml.writer
http.server
http.server.crud
http.server.forms
http.server.actions
http.server.boilerplate
http.server.templating.chloe
http.server.components ;
IN: webapps.planet

TUPLE: blog id name www-url atom-url ;

blog "BLOGS"
{
    { "id" "ID" INTEGER +native-id+ }
    { "name" "NAME" { VARCHAR 256 } +not-null+ }
    { "www-url" "WWWURL" { VARCHAR 256 } +not-null+ }
    { "atom-url" "ATOMURL" { VARCHAR 256 } +not-null+ }
} define-persistent

: init-blog-table blog ensure-table ;

: <blog> ( id -- todo )
    blog new
        swap >>id ;

: planet-template ( name -- template )
    "resource:extra/webapps/planet/" swap ".xml" 3append <chloe> ;

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
        "view-blog" planet-template >>view-template
        "blog-summary" planet-template >>summary-template
        "id" <integer>
            hidden >>renderer
            add-field
        "name" <string>
            t >>required
            add-field
        "www-url" <url>
            t >>required
            add-field
        "atom-url" <url>
            t >>required
            add-field ;

: <planet-factor-form> ( -- form )
    "planet-factor" <form>
        "planet" planet-template >>view-template
        "mini-planet" planet-template >>summary-template
        "postings" <entry-form> +plain+ <list> add-field
        "blogroll" <blog-form> +unordered+ <list> add-field ;

: blogroll ( -- seq )
    f <blog> select-tuples [ [ name>> ] compare ] sort ;

TUPLE: planet-factor < dispatcher postings ;

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

: safe-head ( seq n -- seq' )
    over length min head ;

:: planet-feed ( planet -- feed )
    feed new
        "[ planet-factor ]" >>title
        "http://planet.factorcode.org" >>link
        planet postings>> 30 safe-head >>entries ;

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
    [ atom-url>> fetch-feed ] parallel-map
    [ >r name>> r> [ <posting> ] with map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ pub-date>> ] compare ] sort <reversed> ;

: update-cached-postings ( planet -- )
    "webapps.planet" [
        blogroll fetch-blogroll sort-entries >>postings drop
    ] with-logging ;

:: <update-action> ( planet -- action )
    <action>
        [
            planet update-cached-postings
            "" f <temporary-redirect>
        ] >>display ;

: start-update-task ( planet -- )
    [ update-cached-postings ] curry 10 minutes every drop ;

:: <planet-factor> ( -- responder )
    [let | blog-form [ <blog-form> ]
           blog-ctor [ [ <blog> ] ] |
        planet-factor new-dispatcher
            dup <planet-action> >>default
            dup <feed-action> "feed.xml" add-responder
            dup <update-action> "update" add-responder

            ! Administrative CRUD
                      blog-ctor ""          <delete-action> "delete-blog" add-responder
            blog-form blog-ctor             <view-action>   "view-blog"   add-responder
            blog-form blog-ctor "view-blog" <edit-action>   "edit-blog"   add-responder
    ] ;

USING: namespaces io.files io.sockets
db.sqlite smtp
http.server.db
http.server.sessions
http.server.auth.login
http.server.auth.providers.db
http.server.sessions.storage.db ;

: test-db "planet.db" resource-path sqlite-db ;

: <planet-app> ( -- responder )
    <planet-factor>
    <boilerplate>
        "page" planet-template >>template
    ! <url-sessions>
    !     sessions-in-db >>sessions
    test-db <db-persistence> ;

: init-planet ( -- )
    ! test-db [
    !     init-blog-table
        ! init-users-table
        ! init-sessions-table
    ! ] with-db

    <dispatcher>
        <planet-app> "planet" add-responder
    main-responder set-global ;
