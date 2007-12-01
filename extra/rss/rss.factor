! Copyright (C) 2006 Chris Double, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
IN: rss
USING: xml.utilities kernel assocs xml.generator
    strings sequences xml.data xml.writer
    io.streams.string combinators xml xml.entities io.files io
    http.client namespaces xml.generator hashtables ;

: ?children>string ( tag/f -- string/f )
    [ children>string ] [ f ] if* ;

TUPLE: feed title link entries ;

C: <feed> feed

TUPLE: entry title link description pub-date ;

C: <entry> entry

: rss1.0 ( xml -- feed )
    [
        "channel" tag-named
        [ "title" tag-named children>string ] keep
        "link" tag-named children>string
    ] keep
    "item" tags-named [
        [ "title" tag-named children>string ] keep   
        [ "link" tag-named children>string ] keep
        [ "description" tag-named children>string ] keep
        f "date" "http://purl.org/dc/elements/1.1/" <name>
        tag-named ?children>string
        <entry>
    ] map <feed> ;

: rss2.0 ( xml -- feed )
    "channel" tag-named 
    [ "title" tag-named children>string ] keep
    [ "link" tag-named children>string ] keep
    "item" tags-named [
        [ "title" tag-named children>string ] keep
        [ "link" tag-named ] keep
        [ "guid" tag-named dupd ? children>string ] keep
        [ "description" tag-named children>string ] keep
        "pubDate" tag-named children>string <entry>
    ] map <feed> ;

: atom1.0 ( xml -- feed )
    [ "title" tag-named children>string ] keep
    [ "link" tag-named "href" swap at ] keep
    "entry" tags-named [
        [ "title" tag-named children>string ] keep
        [ "link" tag-named "href" swap at ] keep
        [
            dup "content" tag-named
            [ nip ] [ "summary" tag-named ] if*
            dup tag-children [ tag? ] contains?
            [ tag-children [ write-chunk ] string-out ]
            [ children>string ] if
        ] keep
        dup "published" tag-named
        [ nip ] [ "updated" tag-named ] if*
        children>string <entry>
    ] map <feed> ;

: xml>feed ( xml -- feed )
    dup name-tag {
        { "RDF" [ rss1.0 ] }
        { "rss" [ rss2.0 ] }
        { "feed" [ atom1.0 ] }
    } case ;

: read-feed ( stream -- feed )
    [ read-xml ] with-html-entities xml>feed ;

: download-feed ( url -- feed )
    #! Retrieve an news syndication file, return as a feed tuple.
    http-get-stream rot 200 = [
        nip read-feed
    ] [
        2drop "Error retrieving newsfeed file" throw
    ] if ;

! Atom generation
: entry, ( entry -- )
    << entry >> [
        << title >> [ dup entry-title , ]
        << link [ dup entry-link ] == href // >>
        << published >> [ dup entry-pub-date , ]
        << content >> [ entry-description , ]
    ] ;

: feed>xml ( feed -- xml )
    <XML
        << feed [ "http://www.w3.org/2005/Atom" ] == xmlns >> [
            << title >> [ dup feed-title , ]
            << link [ dup feed-link ] == href // >>
            feed-entries [ entry, ] each
        ]
    XML> ;

: write-feed ( feed -- xml )
    feed>xml write-xml ;
