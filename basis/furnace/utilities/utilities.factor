! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make assocs sequences kernel classes splitting
words vocabs.loader accessors strings combinators arrays
continuations present fry urls http http.server xml.syntax xml.writer
http.server.redirection http.server.remapping ;
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

: each-responder ( quot -- )
   nested-responders swap each ; inline

ERROR: no-such-responder responder ;

: base-path ( string -- seq )
    dup responder-nesting get
    [ second class-of superclasses [ name>> = ] with any? ] with find nip
    [ first ] [ no-such-responder ] ?if ;

: resolve-base-path ( string -- string' )
    "$" ?head [
        [
            "/" split1 [ base-path [  "/" % % ] each "/" % ] dip %
        ] "" make
    ] when ;

: vocab-path ( vocab -- path )
    dup vocab-dir vocab-append-path ;

: resolve-template-path ( pair -- path )
    [
        first2 [ vocabulary>> vocab-path % ] [ "/" % % ] bi*
    ] "" make ;

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
    #! Typo is intentional, it's in the HTTP spec!
    "referer" request get header>> at
    dup [ >url ensure-port [ remap-port ] change-port ] when ;

: user-agent ( -- user-agent )
    "user-agent" request get header>> at "" or ;

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
