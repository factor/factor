! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs http.server http.server.responses kernel
namespaces sequences splitting unicode urls ;
IN: http.server.dispatchers

TUPLE: dispatcher default responders ;

: new-dispatcher ( class -- dispatcher )
    new
        <404> <trivial-responder> >>default
        H{ } clone >>responders ; inline

: <dispatcher> ( -- dispatcher )
    dispatcher new-dispatcher ;

: find-responder ( path dispatcher -- path responder )
    over empty? [
        "" over responders>> at*
        [ nip ] [ drop default>> ] if
    ] [
        over first over responders>> at*
        [ [ drop rest-slice ] dip ] [ drop default>> ] if
    ] if ;

M: dispatcher call-responder*
    find-responder call-responder ;

TUPLE: vhost-dispatcher default responders ;

: <vhost-dispatcher> ( -- dispatcher )
    vhost-dispatcher new-dispatcher ;

: canonical-host ( host -- host' )
    >lower "www." ?head drop "." ?tail drop ;

: find-vhost ( dispatcher -- responder )
    url get host>> canonical-host over responders>> at*
    [ nip ] [ drop default>> ] if ;

M: vhost-dispatcher call-responder*
    find-vhost call-responder ;

: add-responder ( dispatcher responder path -- dispatcher )
    pick responders>> set-at ;

: add-main-responder ( dispatcher responder path -- dispatcher )
    [ add-responder drop ]
    [ drop "" add-responder drop ]
    [ 2drop ] 3tri ;
