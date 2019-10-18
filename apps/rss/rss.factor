! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: rss
USING: kernel http-client xml xml-utils xml-data errors io strings
    sequences xml-writer parser-combinators lazy-lists ;

: ?children>string ( tag/f -- string/f )
    [ children>string ] [ f ] if* ;

LAZY: '&amp;' ( -- parser )
    "&" token
    [ blank? ] satisfy &>
    [ "&amp;" swap add ] <@ ;

: &>&amp; ( string -- string )
    '&amp;' replace ;

TUPLE: feed title link entries ;
TUPLE: entry title link description pub-date ;

: rss1.0 ( xml -- feed )
    [
        "channel" find-tag
        [ "title" find-tag children>string ] keep
        "link" find-tag children>string
    ] keep
    "item" find-tags [
        [ "title" find-tag children>string ] keep   
        [ "link" find-tag children>string ] keep
        [ "description" find-tag children>string ] keep
        f "date" "http://purl.org/dc/elements/1.1/" <name>
        find-name-tag ?children>string
        <entry>
    ] map <feed> ;

: rss2.0 ( xml -- feed )
    "channel" find-tag 
    [ "title" find-tag children>string ] keep
    [ "link" find-tag children>string ] keep
    "item" find-tags [
        [ "title" find-tag children>string ] keep
        [ "link" find-tag ] keep
        [ "guid" find-tag dupd ? children>string ] keep
        [ "description" find-tag children>string ] keep
        "pubDate" find-tag children>string <entry>
    ] map <feed> ;

: atom1.0 ( xml -- feed )
    [ "title" find-tag children>string ] keep
    [ "link" find-tag "href" prop-name-tag first ] keep
    "entry" find-tags [
        [ "title" find-tag children>string ] keep
        [ "link" find-tag "href" prop-name-tag first ] keep
        [
            dup "content" find-tag
            [ nip ] [ "summary" find-tag ] if*
            dup tag-children [ tag? ] contains?
            [ tag-children [ write-chunk ] string-out ]
            [ children>string ] if
        ] keep
        dup "published" find-tag
        [ nip ] [ "updated" find-tag ] if*
        children>string <entry>
    ] map <feed> ;

: feed ( xml -- feed )
    dup name-tag {
        { [ dup "RDF" = ] [ drop rss1.0 ] }
        { [ dup "rss" = ] [ drop rss2.0 ] }
        { [ "feed" = ] [ atom1.0 ] }
        { [ t ] [ "Invalid newsfeed" throw ] }
    } cond ;

: read-feed ( string -- feed )
    ! &>&amp; ! this will be uncommented when parser-combinators are fixed
    string>xml feed ;

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
