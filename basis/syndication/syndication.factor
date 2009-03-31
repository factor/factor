! Copyright (C) 2006 Chris Double, Daniel Ehrenberg.
! Portions copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: xml.traversal kernel assocs math.order strings sequences
xml.data xml.writer io.streams.string combinators xml
xml.entities.html io.files io http.client namespaces make
xml.syntax hashtables calendar.format accessors continuations
urls present byte-arrays ;
IN: syndication

: any-tag-named ( tag names -- tag-inside )
    [ f ] 2dip [ tag-named nip dup ] with find 2drop ;

TUPLE: feed title url entries ;

: <feed> ( -- feed ) feed new ;

TUPLE: entry title url description date ;

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
            >>date
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
        [ { "description" "encoded" } any-tag-named children>string >>description ]
        [
            { "date" "pubDate" } any-tag-named
            children>string try-parsing-timestamp >>date
        ]
    } cleave ;

: rss2.0 ( xml -- feed )
    feed new
    swap
    "channel" tag-named 
    [ "title" tag-named children>string >>title ]
    [ "link" tag-named children>string >url >>url ]
    [ "item" tags-named [ rss2.0-entry ] map set-entries ]
    tri ;

: atom-entry-link ( tag -- url/f )
    "link" tags-named [ "rel" attr "alternate" = ] find nip
    dup [ "href" attr >url ] when ;

: atom1.0-entry ( tag -- entry )
    entry new
    swap {
        [ "title" tag-named children>string >>title ]
        [ atom-entry-link >>url ]
        [
            { "content" "summary" } any-tag-named
            dup children>> [ string? not ] any?
            [ children>> xml>string ]
            [ children>string ] if >>description
        ]
        [
            { "published" "updated" "issued" "modified" } 
            any-tag-named children>string try-parsing-timestamp
            >>date
        ]
    } cleave ;

: atom1.0 ( xml -- feed )
    feed new
    swap
    [ "title" tag-named children>string >>title ]
    [ "link" tag-named "href" attr >url >>url ]
    [ "entry" tags-named [ atom1.0-entry ] map set-entries ]
    tri ;

: xml>feed ( xml -- feed )
    dup main>> {
        { "RDF" [ rss1.0 ] }
        { "rss" [ rss2.0 ] }
        { "feed" [ atom1.0 ] }
    } case ;

GENERIC: parse-feed ( seq -- feed )

M: string parse-feed [ string>xml xml>feed ] with-html-entities ;

M: byte-array parse-feed [ bytes>xml xml>feed ] with-html-entities ;

: download-feed ( url -- feed )
    #! Retrieve an news syndication file, return as a feed tuple.
    http-get nip parse-feed ;

! Atom generation

: entry>xml ( entry -- xml )
    {
        [ title>> ]
        [ url>> present ]
        [ date>> timestamp>rfc3339 ]
        [ description>> ]
    } cleave
    [XML
        <entry>
            <title type="html"><-></title>
            <link href=<-> />
            <published><-></published>
            <content type="html"><-></content>
        </entry>
    XML] ;

: feed>xml ( feed -- xml )
    [ title>> ]
    [ url>> present ]
    [ entries>> [ entry>xml ] map ] tri
    <XML
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title><-></title>
            <link href=<-> />
            <->
        </feed>
    XML> ;
