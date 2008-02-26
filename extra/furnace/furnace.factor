! Copyright (C) 2006, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs calendar debugger furnace.sessions
furnace.validator hashtables heaps html.elements http
http.server.responders http.server.templating io.files kernel
math namespaces quotations sequences splitting words strings
vectors webapps.callback continuations tuples classes vocabs
html io io.encodings.binary ;
IN: furnace

: code>quotation ( word/quot -- quot )
    dup word? [ 1quotation ] when ;

SYMBOL: default-action
SYMBOL: template-path

: render-template ( template -- )
    template-path get swap path+
    ".furnace" append resource-path
    run-template-file ;

: define-action ( word hash -- )
    over t "action" set-word-prop
    "action-params" set-word-prop ;

: define-form ( word1 word2 hash -- )
    dupd define-action
    swap code>quotation "form-failed" set-word-prop ;

: default-values ( word hash -- )
    "default-values" set-word-prop ;

SYMBOL: request-params
SYMBOL: current-action
SYMBOL: validators-errored
SYMBOL: validation-errors

: action-link ( query action -- url )
    [
        "/responder/" %
        dup word-vocabulary "webapps." ?head drop %
        "/" %
        word-name %
    ] "" make swap build-url ;

: action-param ( hash paramsepc -- obj error/f )
    unclip rot at swap >quotation apply-validators ;

: query>seq ( hash word -- seq )
    "action-params" word-prop [
        dup first -rot
        action-param [
            t validators-errored >session
            rot validation-errors session> set-at
        ] [
            nip
        ] if*
    ] with map ;

: lookup-session ( hash -- session )
    "furnace-session-id" over at get-session
    [ ] [ new-session "furnace-session-id" roll set-at ] ?if ;

: quot>query ( seq action -- hash )
    >r >array r> "action-params" word-prop
    [ first swap 2array ] 2map >hashtable ;

PREDICATE: word action "action" word-prop ;

: action-call? ( quot -- ? )
    >vector dup pop action? >r [ word? not ] all? r> and ;

: unclip* dup 1 head* swap peek ;

: quot-link ( quot -- url )
    dup action-call? [
        unclip* [ quot>query ] keep action-link
    ] [
        t register-html-callback
    ] if ;

: replace-variables ( quot -- quot )
    [ dup string? [ request-params session> at ] when ] map ;

: furnace-session-id ( -- hash )
    "furnace-session-id" request-params session> at
    "furnace-session-id" associate ;

: redirect-to-action ( -- )
    current-action session>
    "form-failed" word-prop replace-variables
    quot-link furnace-session-id build-url permanent-redirect ;

: if-form-page ( if then -- )
    current-action session> "form-failed" word-prop -rot if ;

: do-action
    current-action session> [ query>seq ] keep add >quotation call ;

: process-form ( -- )
    H{ } clone validation-errors >session
    request-params session> current-action session> query>seq
    validators-errored session> [
        drop redirect-to-action
    ] [
        current-action session> add >quotation call
    ] if ;

: page-submitted ( -- )
    [ process-form ] [ request-params session> do-action ] if-form-page ;

: action-first-time ( -- )
    request-params session> current-action session>
    [ "default-values" word-prop swap union request-params >session ] keep
    request-params session> do-action ;

: page-not-submitted ( -- )
    [ redirect-to-action ] [ action-first-time ] if-form-page ;

: setup-call-action ( hash word -- )
    over lookup-session session set
    current-action >session
    request-params session> swap union
    request-params >session
    f validators-errored >session ;

: call-action ( hash word -- )
    setup-call-action
    "furnace-form-submitted" request-params session> at
    [ page-submitted ] [ page-not-submitted ] if ;

: responder-vocab ( str -- newstr )
    "webapps." swap append ;

: lookup-action ( str webapp -- word )
    responder-vocab lookup dup [
        dup "action" word-prop [ drop f ] unless
    ] when ;

: truncate-url ( str -- newstr )
    CHAR: / over index [ head ] when* ;

: parse-action ( str -- word/f )
    dup empty? [ drop default-action get ] when
    truncate-url "responder" get lookup-action ;

: service-request ( hash str -- )
    parse-action [
        [ call-action ] [ <pre> print-error </pre> ] recover
    ] [
        "404 no such action: " "argument" get append httpd-error
    ] if* ;

: service-get
    "query" get swap service-request ;

: service-post
    "response" get swap service-request ;

: web-app ( name defaul path -- )
    [
        template-path set
        default-action set
        "responder" set
        [ service-get ] "get" set
        [ service-post ] "post" set
    ] make-responder ;

: explode-tuple ( tuple -- )
    dup tuple-slots swap class "slot-names" word-prop
    [ set ] 2each ;

SYMBOL: model

: with-slots ( model quot -- )
    [
        >r [ dup model set explode-tuple ] when* r> call
    ] with-scope ;

: render-component ( model template -- )
    swap [ render-template ] with-slots ;

: browse-webapp-source ( vocab -- )
    <a vocab browser-link-href =href a>
        "Browse source" write
    </a> ;

: send-resource ( name -- )
    template-path get swap path+ resource-path binary <file-reader>
    stdio get stream-copy ;

: render-link ( quot name -- )
    <a swap quot-link =href a> write </a> ;

: session-var ( str -- newstr )
    request-params session> at ;

: render ( str -- )
    request-params session> at [ write ] when* ;

: render-error ( str error-str -- )
    swap validation-errors session> at validation-error? [
        write
    ] [
        drop
    ] if ;
