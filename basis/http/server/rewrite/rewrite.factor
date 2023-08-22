! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http.server http.server.dispatchers kernel
namespaces sequences splitting urls ;
IN: http.server.rewrite

TUPLE: rewrite param child default ;

: <rewrite> ( -- rewrite )
    rewrite new ;

M: rewrite call-responder*
    over empty? [ default>> ] [
        [ [ first ] [ param>> ] bi* set-param ]
        [ [ rest ] [ child>> ] bi* ]
        2bi
    ] if
    call-responder* ;

TUPLE: vhost-rewrite suffix param child default ;

: <vhost-rewrite> ( -- vhost-rewrite )
    vhost-rewrite new ;

: sub-domain? ( vhost-rewrite url -- subdomain ? )
    swap suffix>> dup [
        [ host>> canonical-host ] [ "." prepend ] bi* ?tail
    ] [ 2drop f f ] if ;

M: vhost-rewrite call-responder*
    dup url get sub-domain?
    [ over param>> set-param child>> ] [ drop default>> ] if
    call-responder ;
