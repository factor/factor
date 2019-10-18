! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel http.server http.server.filters
http.server.responses furnace.utilities ;
IN: furnace.referrer

TUPLE: referrer-check < filter-responder quot ;

C: <referrer-check> referrer-check

M: referrer-check call-responder*
    referrer over quot>> call( referrer -- ? )
    [ call-next-method ]
    [ 2drop 403 "Bad referrer" <trivial-response> ] if ;

: <check-form-submissions> ( responder -- responder' )
    [ post-request? [ same-host? ] [ drop t ] if ] <referrer-check> ;
