! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators continuations
definitions http http.server http.server.redirection
http.server.remapping io.pathnames kernel make namespaces
sequences splitting strings urls words xml.syntax ;
IN: furnace.utilities

: word>string ( word -- string )
    [ vocabulary>> ] [ name>> ] bi ":" glue ;

: words>strings ( seq -- seq' )
    [ word>string ] map ;

ERROR: no-such-word name vocab ;

: string>word ( string -- word )
    ":" split1 swap 2dup lookup-word dup
    [ 2nip ] [ drop no-such-word ] if ;

: strings>words ( seq -- seq' )
    [ string>word ] map ;

: nested-responders ( -- seq )
    responder-nesting get values ;

: each-responder ( quot: ( ... responder -- ... ) -- )
   nested-responders swap each ; inline

ERROR: no-such-responder responder ;

: base-path ( string -- seq )
    [
        responder-nesting get
        [ second class-of superclasses-of [ name>> = ] with any? ] with find nip
    ] [ first ] [ no-such-responder ] ?if ;

: resolve-base-path ( string -- string' )
    "$" ?head [
        [
            "/" split1 [ base-path [ "/" % % ] each "/" % ] dip %
        ] "" make
    ] when ;

: resolve-word-path ( word -- path/f )
    where [ first parent-directory ] [ f ] if* ;

: resolve-template-path ( pair -- path )
    first2 [ resolve-word-path ] dip append-path ;

GENERIC: modify-query ( query responder -- query' )

M: object modify-query drop ;

GENERIC: modify-redirect-query ( query responder -- query' )

M: object modify-redirect-query drop ;

GENERIC: adjust-url ( url -- url' )

M: url adjust-url
    clone
        [ [ modify-query ] each-responder ] change-query
        [ resolve-base-path ] change-path
    relative-to-request ;

M: string adjust-url ;

GENERIC: adjust-redirect-url ( url -- url' )

M: url adjust-redirect-url
    adjust-url
    [ [ modify-redirect-query ] each-responder ] change-query ;

M: string adjust-redirect-url ;

GENERIC: link-attr ( tag responder -- )

M: object link-attr 2drop ;

GENERIC: modify-form ( responder -- xml/f )

M: object modify-form drop f ;

: form-modifications ( -- xml )
    [ [ modify-form [ , ] when* ] each-responder ] { } make ;

: hidden-form-field ( value name -- xml )
    over [
        [XML <input type="hidden" value=<-> name=<->/> XML]
    ] [ drop ] if ;

CONSTANT: nested-forms-key "__n"

: referrer ( -- referrer/f )
    ! Typo is intentional, it's in the HTTP spec!
    request get "referer" header
    dup [ >url ensure-port [ remap-port ] change-port ] when ;

: user-agent ( -- user-agent )
    request get "user-agent" header "" or ;

: same-host? ( url -- ? )
    dup [
        url get [
            [ protocol>> ]
            [ host>> ]
            [ port>> remap-port ]
            tri 3array
        ] same?
    ] when ;

: cookie-client-state ( key request -- value/f )
    swap get-cookie dup [ value>> ] when ;

: post-client-state ( key request -- value/f )
    request-params at ;

: client-state ( key -- value/f )
    request get dup method>> {
        { "GET" [ cookie-client-state ] }
        { "HEAD" [ cookie-client-state ] }
        { "POST" [ post-client-state ] }
    } case ;

SYMBOL: exit-continuation

: exit-with ( value -- * )
    exit-continuation get continue-with ;

: with-exit-continuation ( quot -- value )
    '[ exit-continuation set @ ] callcc1 exit-continuation off ; inline
