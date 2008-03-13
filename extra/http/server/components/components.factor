! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: new-slots html.elements http.server.validators accessors
namespaces kernel io math.parser assocs classes words tuples
arrays sequences io.files http.server.templating.fhtml
http.server.actions splitting mirrors hashtables
combinators.cleave fry continuations math ;
IN: http.server.components

SYMBOL: validation-failed?

SYMBOL: components

TUPLE: component id required default ;

: component ( name -- component )
    dup components get at
    [ ] [ "No such component: " swap append throw ] ?if ;

GENERIC: validate* ( value component -- result )
GENERIC: render-view* ( value component -- )
GENERIC: render-edit* ( value component -- )
GENERIC: render-error* ( reason value component -- )

SYMBOL: values

: value values get at ;

: set-value values get set-at ;

: validate ( value component -- result )
    '[
        , ,
        over empty? [
            [ default>> [ v-default ] when* ]
            [ required>> [ v-required ] when ]
            bi
        ] [ validate* ] if
    ] [
        dup validation-error?
        [ validation-failed? on ] [ rethrow ] if
    ] recover ;

: render-view ( component -- )
    [ id>> value ] [ render-view* ] bi ;

: render-error ( error -- )
    <span "error" =class span> write </span> ;

: render-edit ( component -- )
    dup id>> value dup validation-error? [
        [ reason>> ] [ value>> ] bi rot render-error*
    ] [
        swap [ default>> or ] keep render-edit*
    ] if ;

: <component> ( id class -- component )
    \ component construct-empty
    swap construct-delegate
    swap >>id ; inline

! Forms
TUPLE: form view-template edit-template components ;

: <form> ( id -- form )
    form <component>
        V{ } clone >>components ;

: add-field ( form component -- form )
    dup id>> pick components>> set-at ;

: with-form ( form quot -- )
    >r components>> components r> with-variable ; inline

: set-defaults ( form -- )
    [
        components get [
            swap values get [
                swap default>> or
            ] change-at
        ] assoc-each
    ] with-form ;

: view-form ( form -- )
    dup view-template>> '[ , run-template ] with-form ;

: edit-form ( form -- )
    dup edit-template>> '[ , run-template ] with-form ;

: validate-param ( id component -- )
    [ [ params get at ] [ validate ] bi* ]
    [ drop set-value ] 2bi ;

: (validate-form) ( form -- error? )
    [
        validation-failed? off
        components get [ validate-param ] assoc-each
        validation-failed? get
    ] with-form ;

: validate-form ( form -- )
    (validate-form) [ validation-failed ] when ;

: blank-values H{ } clone values set ;

: from-tuple <mirror> values set ;

: values-tuple values get mirror-object ;

! ! !
! Canned components: for simple applications and prototyping
! ! !

: render-input ( value component type -- )
    <input
    =type
    id>> [ =id ] [ =name ] bi
    =value
    input/> ;

! Hidden fields
TUPLE: hidden ;

: <hidden> ( component -- component )
    hidden construct-delegate ;

M: hidden render-view*
    2drop ;

M: hidden render-edit*
    >r dup number? [ number>string ] when r>
    "hidden" render-input ;

! String input fields
TUPLE: string min-length max-length ;

: <string> ( id -- component ) string <component> ;

M: string validate*
    [ v-one-line ] [
        [ min-length>> [ v-min-length ] when* ]
        [ max-length>> [ v-max-length ] when* ]
        bi
    ] bi* ;

M: string render-view*
    drop write ;

M: string render-edit*
    "text" render-input ;

M: string render-error*
    "text" render-input render-error ;

! Username fields
TUPLE: username ;

: <username> ( id -- component )
    <string> username construct-delegate
        2 >>min-length
        20 >>max-length ;

M: username validate*
    delegate validate* v-one-word ;

! E-mail fields
TUPLE: email ;

: <email> ( id -- component )
    <string> email construct-delegate
        5 >>min-length
        60 >>max-length ;

M: email validate*
    delegate validate* dup empty? [ v-email ] unless ;

! Password fields
TUPLE: password ;

: <password> ( id -- component )
    <string> password construct-delegate
        6 >>min-length
        60 >>max-length ;

M: password validate*
    delegate validate* v-one-word ;

M: password render-edit*
    >r drop f r> "password" render-input ;

M: password render-error*
    render-edit* render-error ;

! Number fields
TUPLE: number min-value max-value ;

: <number> ( id -- component ) number <component> ;

M: number validate*
    [ v-number ] [
        [ min-value>> [ v-min-value ] when* ]
        [ max-value>> [ v-max-value ] when* ]
        bi
    ] bi* ;

M: number render-view*
    drop number>string write ;

M: number render-edit*
    >r number>string r> "text" render-input ;

M: number render-error*
    "text" render-input render-error ;

! Text areas
TUPLE: text ;

: <text> ( id -- component ) <string> text construct-delegate ;

: render-textarea
    <textarea
        id>> [ =id ] [ =name ] bi
    textarea>
        write
    </textarea> ;

M: text render-edit*
    render-textarea ;

M: text render-error*
    render-textarea render-error ;

! Simple captchas
TUPLE: captcha ;

: <captcha> ( id -- component )
    <string> captcha construct-delegate ;

M: captcha validate*
    drop v-captcha ;
