! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple colors.constants
colors.hex combinators formatting fry http.client io io.styles
json.reader kernel make math sequences splitting urls ;
IN: hacker-news

TUPLE: post title postedBy points id url commentCount postedAgo ;

: items> ( seq -- seq' )
    [ \ post from-slots ] map ;

: hacker-news-items ( -- seq )
    "http://api.ihackernews.com/page" http-get nip
    json> "items" swap at items> ;

: write-title ( title url -- )
    '[
        _ presented ,,
        COLOR: black foreground ,,
    ] H{ } make format ;

: write-link ( title url -- )
    '[
        _ presented ,,
        HEXCOLOR: 888888 foreground ,,
    ] H{ } make format ;

: write-text ( str -- )
    H{ { foreground HEXCOLOR: 888888 } } format ;

: post>user-url ( post -- user-url )
    postedBy>> "http://news.ycombinator.com/user?id=" prepend >url ;

: post>comments-url ( post -- user-url )
    id>> "http://news.ycombinator.com/item?id=%d" sprintf >url ;


: post. ( post index -- )
    "%2d. " sprintf write-text {
        [ [ title>> ] [ url>> ] bi write-title ]
        [ url>> >url host>> " (" ")" surround write-text nl ]
        [ points>> "    %d points" sprintf write-text ]
        [ " by " write-text [ postedBy>> ] [ post>user-url ] bi write-link ]
        [ " " write-text postedAgo>> write-text ]
        [
            "|" write-text
            [ commentCount>> "%d comments" sprintf ]
            [ post>comments-url ] bi write-link nl nl
        ]
    } cleave ;

: banner. ( -- )
    "Hacker News"
    H{
        { font-size 20 }
        { font-style bold }
        { background HEXCOLOR: ff6600 }
    } format nl ;

: hacker-news. ( -- )
    hacker-news-items banner.
    [ 1 + post. ] each-index ;
