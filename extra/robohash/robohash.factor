! Copyright (C) 2011 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: images.http kernel sequences urls urls.encoding ;

IN: robohash

<PRIVATE

: robohash-url ( str -- url )
    url-encode "https://robohash.org/" prepend >url ;

: (robohash) ( str type -- image )
    [ robohash-url ] [ "set" set-query-param ] bi*
    load-http-image ;

PRIVATE>

: robohash1 ( str -- image ) "set1" (robohash) ;

: robohash2 ( str -- image ) "set2" (robohash) ;

: robohash3 ( str -- image ) "set3" (robohash) ;
