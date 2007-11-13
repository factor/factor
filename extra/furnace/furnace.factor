! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vectors io assocs quotations splitting strings 
       words sequences namespaces arrays hashtables debugger
       continuations tuples classes io.files 
       http http.server.templating http.basic-authentication 
       webapps.callback html html.elements 
       http.server.responders furnace.validator ;
IN: furnace

SYMBOL: default-action

SYMBOL: template-path

: define-authenticated-action ( word params realm -- )
    pick swap "action-realm" set-word-prop
    over t "action" set-word-prop
    "action-params" set-word-prop ;

: define-action ( word params -- )
    f define-authenticated-action ;

: define-redirect ( word quot -- )
    "action-redirect" set-word-prop ;

: responder-vocab ( name -- vocab )
    "webapps." swap append ;

: lookup-action ( name webapp -- word )
    responder-vocab lookup dup [
        dup "action" word-prop [ drop f ] unless
    ] when ;

: truncate-url ( url -- action-name )
  CHAR: / over index [ head ] when* ;

: current-action ( url -- word/f )
    dup empty? [ drop default-action get ] when
    truncate-url "responder" get lookup-action ;

PREDICATE: word action "action" word-prop ;

: quot>query ( seq action -- hash )
    >r >array r> "action-params" word-prop
    [ first swap 2array ] 2map >hashtable ;

: action-link ( query action -- url )
    [
        "/responder/" %
        dup word-vocabulary "webapps." ?head drop %
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
    unclip rot at swap >quotation apply-validators ;

: query>quot ( params action -- seq )
    "action-params" word-prop [ action-param drop ] curry* map ;

SYMBOL: request-params

: perform-redirect ( action -- )
    "action-redirect" word-prop
    [ dup string? [ request-params get at ] when ] map
    [ quot-link permanent-redirect ] when* ;

: (call-action) ( params action -- )
    over request-params set
    [ query>quot ] keep [ add >quotation call ] keep
    perform-redirect ;

: call-action ( params action -- )
    dup "action-realm" word-prop [
        [ (call-action) ] with-basic-authentication
    ] [ (call-action) ] if* ;

: service-request ( params url -- )
    current-action [
        [ call-action ] [ <pre> print-error </pre> ] recover
    ] [
        "404 no such action: " "argument" get append httpd-error
    ] if* ;

: service-get ( url -- ) "query" get swap service-request ;

: service-post ( url -- ) "response" get swap service-request ;

: explode-tuple ( tuple -- )
    dup tuple-slots swap class "slot-names" word-prop
    [ set ] 2each ;

SYMBOL: model

: call-template ( model template -- )
    [
        >r [ dup model set explode-tuple ] when* r>
        ".furnace" append resource-path run-template-file
    ] with-scope ;

: render-template ( model template -- )
    template-path get swap path+ call-template ;

: render-page* ( model body-template head-template -- )
    [
        [ render-template ] [ f rot render-template ] html-document 
    ] serve-html ;

: render-titled-page* ( model body-template head-template title -- )
    [ 
        [ render-template ] swap [ <title> write </title> f rot render-template ] curry html-document
    ] serve-html ;


: render-page ( model template title -- )
    [
        [ render-template ] simple-html-document
    ] serve-html ;

: web-app ( name default path -- )
    [
        template-path set
        default-action set
        "responder" set
        [ service-get ] "get" set
        [ service-post ] "post" set
        ! [ service-head ] "head" set
    ] make-responder ;
