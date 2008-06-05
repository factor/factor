! Copyright (C) 2006 Chris Double, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml.utilities kernel assocs xml.generator math.order
    strings sequences xml.data xml.writer
    io.streams.string combinators xml xml.entities io.files io
    http.client namespaces xml.generator hashtables
    calendar.format accessors continuations urls present ;
IN: rss

: any-tag-named ( tag names -- tag-inside )
    f -rot [ tag-named nip dup ] with find 2drop ;

TUPLE: feed title url entries ;

: <feed> ( -- feed ) feed new ;

TUPLE: entry title url description pub-date ;

: set-entries ( feed entries -- feed )
    [ dup url>> ] dip
    [ [ derive-url ] change-url ] with map
    >>entries ;

: <entry> ( -- entry ) entry new ;

: try-parsing-timestamp ( string -- timestamp )
    [ rfc822>timestamp ] [ drop rfc3339>timestamp ] recover ;

: rss1.0-entry ( tag -- entry )
    entry new
    swap {
        [ "title" tag-named children>string >>title ]
        [ "link" tag-named children>string >url >>url ]
        [ "description" tag-named children>string >>description ]
        [
            f "date" "http://purl.org/dc/elements/1.1/" <name>
            tag-named dup [ children>string try-parsing-timestamp ] when
            >>pub-date
        ]
    } cleave ;

: rss1.0 ( xml -- feed )
    feed new
    swap [
        "channel" tag-named
        [ "title" tag-named children>string >>title ]
        [ "link" tag-named children>string >url >>url ] bi
    ] [ "item" tags-named [ rss1.0-entry ] map set-entries ] bi ;

: rss2.0-entry ( tag -- entry )
    entry new
    swap {
        [ "title" tag-named children>string >>title ]
        [ { "link" "guid" } any-tag-named children>string >url >>url ]
        [ "description" tag-named children>string >>description ]
        [
            { "date" "pubDate" } any-tag-named
            children>string try-parsing-timestamp >>pub-date
        ]
    } cleave ;

: rss2.0 ( xml -- feed )
    feed new
    swap
    "channel" tag-named 
    [ "title" tag-named children>string >>title ]
    [ "link" tag-named children>string >>link ]
    [ "item" tags-named [ rss2.0-entry ] map set-entries ]
    tri ;

: atom1.0-entry ( tag -- entry )
    entry new
    swap {
        [ "title" tag-named children>string >>title ]
        [ "link" tag-named "href" swap at >url >>url ]
        [
            { "content" "summary" } any-tag-named
            dup tag-children [ string? not ] contains?
            [ tag-children [ write-chunk ] with-string-writer ]
            [ children>string ] if >>description
        ]
        [
            { "published" "updated" "issued" "modified" } 
            any-tag-named children>string try-parsing-timestamp
            >>pub-date
        ]
    } cleave ;

: atom1.0 ( xml -- feed )
    feed new
    swap
    [ "title" tag-named children>string >>title ]
    [ "link" tag-named "href" swap at >url >>url ]
    [ "entry" tags-named [ atom1.0-entry ] map set-entries ]
    tri ;

: xml>feed ( xml -- feed )
    dup name-tag {
        { "RDF" [ rss1.0 ] }
        { "rss" [ rss2.0 ] }
        { "feed" [ atom1.0 ] }
    } case ;

: read-feed ( string -- feed )
    [ string>xml xml>feed ] with-html-entities ;

: download-feed ( url -- feed )
    #! Retrieve an news syndication file, return as a feed tuple.
    http-get read-feed ;

! Atom generation
: simple-tag, ( content name -- )
    [ , ] tag, ;

: simple-tag*, ( content name attrs -- )
    [ , ] tag*, ;

: entry, ( entry -- )
    "entry" [
        {
            [ title>> "title" { { "type" "html" } } simple-tag*, ]
            [ url>> present "href" associate "link" swap contained*, ]
            [ pub-date>> timestamp>rfc3339 "published" simple-tag, ]
            [ description>> [ "content" { { "type" "html" } } simple-tag*, ] when* ]
        } cleave
    ] tag, ;

: feed>xml ( feed -- xml )
    "feed" { { "xmlns" "http://www.w3.org/2005/Atom" } } [
        [ title>> "title" simple-tag, ]
        [ url>> present "href" associate "link" swap contained*, ]
        [ entries>> [ entry, ] each ]
        tri
    ] make-xml* ;
