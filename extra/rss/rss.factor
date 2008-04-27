! Copyright (C) 2006 Chris Double, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml.utilities kernel assocs xml.generator math.order
    strings sequences xml.data xml.writer
    io.streams.string combinators xml xml.entities io.files io
    http.client namespaces xml.generator hashtables
    calendar.format accessors continuations ;
IN: rss

: any-tag-named ( tag names -- tag-inside )
    f -rot [ tag-named nip dup ] with find 2drop ;

TUPLE: feed title link entries ;

C: <feed> feed

TUPLE: entry title link description pub-date ;

C: <entry> entry

: rss1.0-entry ( tag -- entry )
    [ "title" tag-named children>string ] keep   
    [ "link" tag-named children>string ] keep
    [ "description" tag-named children>string ] keep
    f "date" "http://purl.org/dc/elements/1.1/" <name>
    tag-named dup [ children>string rfc822>timestamp ] when
    <entry> ;

: rss1.0 ( xml -- feed )
    [
        "channel" tag-named
        [ "title" tag-named children>string ] keep
        "link" tag-named children>string
    ] keep
    "item" tags-named [ rss1.0-entry ] map <feed> ;

: rss2.0-entry ( tag -- entry )
    [ "title" tag-named children>string ] keep
    [ "link" tag-named ] keep
    [ "guid" tag-named dupd ? children>string ] keep
    [ "description" tag-named children>string ] keep
    "pubDate" tag-named children>string rfc822>timestamp <entry> ;

: rss2.0 ( xml -- feed )
    "channel" tag-named 
    [ "title" tag-named children>string ] keep
    [ "link" tag-named children>string ] keep
    "item" tags-named [ rss2.0-entry ] map <feed> ;

: atom1.0-entry ( tag -- entry )
    [ "title" tag-named children>string ] keep
    [ "link" tag-named "href" swap at ] keep
    [
        { "content" "summary" } any-tag-named
        dup tag-children [ string? not ] contains?
        [ tag-children [ write-chunk ] with-string-writer ]
        [ children>string ] if
    ] keep
    { "published" "updated" "issued" "modified" } any-tag-named
    children>string rfc3339>timestamp <entry> ;

: atom1.0 ( xml -- feed )
    [ "title" tag-named children>string ] keep
    [ "link" tag-named "href" swap at ] keep
    "entry" tags-named [ atom1.0-entry ] map <feed> ;

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
        dup entry-title "title" { { "type" "html" } } simple-tag*,
        "link" over entry-link "href" associate contained*,
        dup entry-pub-date timestamp>rfc3339 "published" simple-tag,
        entry-description [ "content" { { "type" "html" } } simple-tag*, ] when*
    ] tag, ;

: feed>xml ( feed -- xml )
    "feed" { { "xmlns" "http://www.w3.org/2005/Atom" } } [
        dup feed-title "title" simple-tag,
        "link" over feed-link "href" associate contained*,
        feed-entries [ entry, ] each
    ] make-xml* ;

: write-feed ( feed -- )
    feed>xml write-xml ;
