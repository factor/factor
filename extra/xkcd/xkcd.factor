! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting http.client images.http images.viewer io
kernel regexp sequences strings ui wrap.strings xml
xml.traversal ;

IN: xkcd

<PRIVATE

: xkcd-image. ( url -- )
    http-get nip
    R" http://imgs\.xkcd\.com/comics/[^\.]+\.(png|jpg)"
    first-match >string load-http-image image. ;

: xkcd-text. ( url -- )
    http-get nip string>xml
    "transcript" "id" deep-tag-with-attr children>string
    80 wrap-lines [ print ] each ;

: comic. ( url -- )
    ui-running? [ xkcd-image. ] [ xkcd-text. ] if ;

PRIVATE>

: xkcd. ( n -- )
    "http://xkcd.com/%s/" sprintf comic. ;

: random-xkcd. ( -- )
    "http://dynamic.xkcd.com/random/comic/" comic. ;

: latest-xkcd. ( -- )
    "http://xkcd.com" comic. ;
