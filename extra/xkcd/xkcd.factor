! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting http.client images.http images.viewer kernel
regexp strings ;

IN: xkcd

<PRIVATE

: load-comic ( url -- image )
    http-get nip
    R" http://imgs\.xkcd\.com/comics/[^\.]+\.(png|jpg)"
    first-match >string load-http-image ;

PRIVATE>

: xkcd. ( n -- )
    "http://xkcd.com/%s/" sprintf load-comic image. ;

: random-xkcd. ( -- )
    "http://dynamic.xkcd.com/random/comic/" load-comic image. ;

: latest-xkcd. ( -- )
    "http://xkcd.com" load-comic image. ;
