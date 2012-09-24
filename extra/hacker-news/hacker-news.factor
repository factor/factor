! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple colors.constants
colors.hex combinators formatting fry http.client io io.styles
json.reader kernel make math sequences splitting urls json
math.parser hashtables ;
IN: hacker-news

TUPLE: post title postedBy points id url commentCount postedAgo ;

<PRIVATE

: json-null>f ( obj -- obj/f )
    dup json-null = [ drop f ] when ;

: items> ( seq -- seq' )
    [
        \ post from-slots
        [ json-null>f ] change-postedAgo
        [ json-null>f ] change-postedBy
        dup url>> "/comments" head? [
            dup url>> "/" split last string>number >>id
            "self" >>url
        ] when
    ] map ;

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

! Api is funky, gives id=0 and /comment/2342342 for self-post ads
: post>url ( post -- url )
    dup url>> "self" = [
        post>comments-url
    ] [
        url>> >url
    ] if ;

PRIVATE>

: post. ( post index -- )
    "%2d. " sprintf write-text {
        [ [ title>> ] [ post>url ] bi write-title ]
        [ post>url host>> " (" ")" surround write-text nl ]
        [ points>> "    %d points" sprintf write-text ]
        [ dup postedBy>> [ " by " write-text [ postedBy>> ] [ post>user-url ] bi write-link ] [ drop ] if ]
        [ dup postedAgo>> [ " " write-text postedAgo>> write-text ] [ drop ] if ]
        [
            " | " write-text
            [ commentCount>> [ "discuss" ] [ "%d comments" sprintf ] if-zero ]
            [ post>comments-url ] bi write-link nl nl
        ]
    } cleave ;

: banner. ( -- )
    "Hacker News"
    "http://news.ycombinator.com" >url presented associate
    H{
        { font-size 20 }
        { font-style bold }
        { background HEXCOLOR: ff6600 }
    } assoc-union format nl ;

: hacker-news. ( -- )
    hacker-news-items banner.
    [ 1 + post. ] each-index ;
