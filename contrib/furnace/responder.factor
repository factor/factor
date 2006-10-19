! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: furnace
USING: embedded generic arrays namespaces prettyprint io
sequences words kernel httpd html errors hashtables http
callback-responder vectors strings ;

SYMBOL: default-action

SYMBOL: template-path

: define-action ( word params -- )
    over t "action" set-word-prop
    "action-params" set-word-prop ;

: define-redirect ( word quot -- )
    "action-redirect" set-word-prop ;

: responder-vocab ( name -- vocab )
    "furnace:" swap append ;

: lookup-action ( name webapp -- word )
    responder-vocab lookup dup [
        dup "action" word-prop [ drop f ] unless
    ] when ;

: current-action ( url -- word/f )
    dup empty? [ drop default-action get ] when
    "responder" get lookup-action ;

PREDICATE: word action "action" word-prop ;

: quot>query ( seq action -- hash )
    "action-params" word-prop
    [ first swap 2array ] 2map alist>hash ;

: action-link ( query action -- url )
    [
        "/responder/" %
        dup word-vocabulary "furnace:" ?head drop %
        "/" %
        word-name %
    ] "" make swap build-url ;

: action-call? ( quot -- ? )
    >vector dup pop action? >r [ word? not ] all? r> and ;

: unclip* dup 1 head* swap peek ;

: quot-link ( quot -- url )
    dup action-call? [
        unclip* [ quot>query ] keep action-link
    ] [
        t register-html-callback
    ] if ;

: render-link ( quot name -- )
    <a swap quot-link =href a> write </a> ;

: action-param ( params paramspec -- obj error/f )
    unclip rot hash swap >quotation apply-validators ;

: query>quot ( params action -- seq )
    "action-params" word-prop [ action-param drop ] map-with ;

SYMBOL: request-params

: perform-redirect ( action -- )
    "action-redirect" word-prop
    [ dup string? [ request-params get hash ] when ] map
    [ quot-link redirect ] when* ;

: call-action ( params action -- )
    over request-params set
    [ query>quot ] keep [ add >quotation call ] keep
    perform-redirect ;

: service-request ( params url -- )
    current-action [
        [ call-action ] [ <pre> print-error </pre> ] recover
    ] [
        "404 no such action: " "argument" get append httpd-error
    ] if* ;

: service-get ( url -- ) "query" get swap service-request ;

: service-post ( url -- ) "response" get swap service-request ;

: explode-tuple ( tuple -- )
    dup tuple>array 2 tail swap class "slot-names" word-prop
    [ set ] 2each ;

SYMBOL: model

: call-template ( model template -- )
    [
        >r [ dup model set explode-tuple ] when* r>
        ".fhtml" append resource-path run-embedded-file
    ] with-scope ;

: render-template ( model template -- )
    template-path get swap path+ call-template ;

: render-page ( model template title -- )
    [
        [
            render-template
        ] html-document
    ] with-html-stream ;

: web-app ( name default path -- )
    over responder-vocab create-vocab drop
    [
        template-path set
        default-action set
        "responder" set
        [ service-get ] "get" set
        [ service-post ] "post" set
        ! [ service-head ] "head" set
    ] make-responder ;
