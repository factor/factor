IN: furnace
USING: embedded generic arrays namespaces prettyprint io
sequences words kernel httpd html errors hashtables http
callback-responder ;

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
        "/responder/" % "responder" get % "/" %
        word-name %
    ] "" make swap build-url ;

: action-call? ( args obj -- ? )
    action? >r [ word? not ] all? r> and ;

: quot-link ( quot -- url )
    1 swap cut* peek 2dup action-call? [
        [ quot>query ] keep action-link
    ] [
        t register-html-callback
    ] if ;

: render-link ( quot name -- )
    <a swap quot-link =href a> write </a> ;

: query>quot ( params action -- seq )
    "action-params" word-prop
    [ dup first rot hash [ ] [ second ] ?if ] map-with ;

: perform-redirect ( action -- )
    "action-redirect" word-prop [ quot-link redirect ] when* ;

: call-action ( params action -- )
    [ query>quot ] keep [ add >quotation call ] keep
    perform-redirect ;

: service-request ( url params -- )
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

: call-template ( model template -- )
    [
        >r [ explode-tuple ] when* r>
        ".fhtml" append resource-path run-embedded-file
    ] with-scope ;

TUPLE: component model template ;

TUPLE: page title root ;

C: page ( title model template -- page )
    [ >r <component> r> set-page-root ] keep
    [ set-page-title ] keep ;

: render-template ( model template -- )
    template-path get swap path+ call-template ;

: render-component
    dup component-model swap component-template
    render-template ;

: render-page ( title model template -- )
    serving-html
    <page> "contrib/furnace/page" call-template ;

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
