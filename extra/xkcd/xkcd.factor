! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors formatting http.client images.http
images.viewer io kernel math parser prettyprint.custom regexp
sequences strings ui wrap.strings xml xml.traversal ;

IN: xkcd

<PRIVATE

: comic-image ( url -- image )
    http-get nip
    R" http://imgs\.xkcd\.com/comics/[^\.]+\.(png|jpg)"
    first-match >string load-http-image ;

: comic-image. ( url -- ) comic-image image. ;

: comic-string ( url -- string )
    http-get nip string>xml
    "transcript" "id" deep-tag-with-attr children>string ;

: comic-text. ( url -- )
    comic-image
    80 wrap-lines [ print ] each ;

: comic. ( url -- )
    ui-running? [ comic-image. ] [ comic-text. ] if ;

PRIVATE>

: xkcd-url ( n -- url )
    "http://xkcd.com/%s/" sprintf ;

: xkcd-image ( n -- image )
    xkcd-url comic-image ;

: xkcd. ( n -- )
    xkcd-url comic. ;

: random-xkcd. ( -- )
    "http://dynamic.xkcd.com/random/comic/" comic. ;

: latest-xkcd. ( -- )
    "http://xkcd.com" comic. ;

TUPLE: xkcd image ;

C: <xkcd> xkcd

SYNTAX: XKCD: scan-number xkcd-image <xkcd> suffix! ;

M: xkcd pprint* image>> image. ;
