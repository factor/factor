! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs http.client images.loader
images.loader.private images.viewer io.pathnames kernel
namespaces present sequences ;
IN: images.http

<PRIVATE

: content-type ( response -- type/f )
    content-type>> dup "image/" head?
    [ 6 tail ] [ drop f ] if ;

PRIVATE>

: load-http-image ( path -- image )
    [ http-get swap content-type ]
    [ present file-extension ] bi or
    (image-class) load-image* ;

: http-image. ( path -- )
    load-http-image image. ;
