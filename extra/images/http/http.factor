! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit http.client
images.loader images.loader.private images.viewer io.pathnames
kernel namespaces present sequences strings urls ;
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

M: string set-image
    dup { [ "http://" head? ] [ "https://" head? ] } 1||
    [ load-http-image ] [ load-image ] if >>image ;

M: url set-image
    protocol>> load-http-image >>image ;

: http-image. ( path -- )
    load-http-image image. ;
