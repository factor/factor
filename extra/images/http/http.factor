! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: http.client images.loader images.loader.private kernel
images.viewer ;
IN: images.http

: load-http-image ( path -- image )
    [ http-get nip ] [ image-class ] bi load-image* ;

: http-image. ( path -- )
    load-http-image image. ;
