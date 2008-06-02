! Copyright (C) 2006 Chris Double, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml.utilities kernel assocs xml.generator math.order
    strings sequences xml.data xml.writer
    io.streams.string combinators xml xml.entities io.files io
    http.client namespaces xml.generator hashtables
    calendar.format accessors continuations urls ;
IN: rss

: any-tag-named ( tag names -- tag-inside )
    f -rot [ tag-named nip dup ] with find 2drop ;

TUPLE: feed title link entries ;

C: <feed> feed

TUPLE: entry title link description pub-date ;

C: <entry> entry

: try-parsing-timestamp ( string -- timestamp )
    [ rfc822>timestamp ] [ drop rfc3339>timestamp ] recover ;

: rss1.0-entry ( tag -- entry )
    {
        [ "title" tag-named children>string ]
        [ "link" tag-named children>string ]
        [ "description" tag-named children>string ]
        [
            f "date" "http://purl.org/dc/elements/1.1/" <name>
            tag-named dup [ children>string try-parsing-timestamp ] when
        ]
    } cleave <entry> ;

: rss1.0 ( xml -- feed )
    [
        "channel" tag-named
        [ "title" tag-named children>string ]
        [ "link" tag-named children>string ] bi
    ] [ "item" tags-named [ rss1.0-entry ] map ] bi
    <feed> ;

: rss2.0-entry ( tag -- entry )
    {
        [ "title" tag-named children>string ]
        [ { "link" "guid" } any-tag-named children>string ]
        [ "description" tag-named children>string ]
        [
            { "date" "pubDate" } any-tag-named
            children>string try-parsing-timestamp
        ]
    } cleave <entry> ;

: rss2.0 ( xml -- feed )
    "channel" tag-named 
    [ "title" tag-named children>string ]
    [ "link" tag-named children>string ]
    [ "item" tags-named [ rss2.0-entry ] map ]
    tri <feed> ;

: atom1.0-entry ( tag -- entry )
    {
        [ "title" tag-named children>string ]
        [ "link" tag-named "href" swap at ]
        [
            { "content" "summary" } any-tag-named
            dup tag-children [ string? not ] contains?
            [ tag-children [ write-chunk ] with-string-writer ]
            [ children>string ] if
        ]
        [
            { "published" "updated" "issued" "modified" } 
            any-tag-named children>string try-parsing-timestamp
        ]
    } cleave <entry> ;

: atom1.0 ( xml -- feed )
    [ "title" tag-named children>string ]
    [ "link" tag-named "href" swap at ]
    [ "entry" tags-named [ atom1.0-entry ] map ]
    tri <feed> ;

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
        dup title>> "title" { { "type" "html" } } simple-tag*,
        "link" over link>> dup url? [ url>string ] when "href" associate contained*,
        dup pub-date>> timestamp>rfc3339 "published" simple-tag,
        description>> [ "content" { { "type" "html" } } simple-tag*, ] when*
    ] tag, ;

: feed>xml ( feed -- xml )
    "feed" { { "xmlns" "http://www.w3.org/2005/Atom" } } [
        dup title>> "title" simple-tag,
        "link" over link>> dup url? [ url>string ] when "href" associate contained*,
        entries>> [ entry, ] each
    ] make-xml* ;
