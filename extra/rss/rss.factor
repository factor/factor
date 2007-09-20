! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: rss
! USING: kernel http-client xml xml-utils xml-data errors io strings
!    sequences xml-writer parser-combinators lazy-lists entities ;
USING: xml.utilities kernel promises parser-combinators assocs
    parser-combinators.replace strings sequences xml.data xml.writer
    io.streams.string combinators xml xml.entities io.files io
    http.client ;

: ?children>string ( tag/f -- string/f )
    [ children>string ] [ f ] if* ;

LAZY: '&amp;' ( -- parser )
    "&" token
    [ blank? ] satisfy &>
    [ "&amp;" swap add ] <@ ;

: &>&amp; ( string -- string )
    '&amp;' replace ;

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

: feed ( xml -- feed )
    dup name-tag {
        { "RDF" [ rss1.0 ] }
        { "rss" [ rss2.0 ] }
        { "feed" [ atom1.0 ] }
    } case ;

: read-feed ( string -- feed )
    ! &>&amp; ! this will be uncommented when parser-combinators are fixed
    [ string>xml ] with-html-entities feed ;

: load-news-file ( filename -- feed )
    #! Load an news syndication file and process it, returning
    #! it as an feed tuple.
    <file-reader> [ contents read-feed ] keep stream-close ;

: news-get ( url -- feed )
    #! Retrieve an news syndication file, return as a feed tuple.
    http-get rot 200 = [
        nip read-feed
    ] [
        2drop "Error retrieving newsfeed file" throw
    ] if ;
