! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel io math.parser assocs classes
words classes.tuple arrays sequences splitting mirrors
hashtables fry combinators continuations math
calendar.format html.elements
http.server.validators ;
IN: http.server.components

! Renderer protocol
GENERIC: render-summary* ( value renderer -- )
GENERIC: render-view* ( value renderer -- )
GENERIC: render-edit* ( value id renderer -- )

M: object render-summary* render-view* ;

TUPLE: field type ;

C: <field> field

M: field render-view* drop write ;

M: field render-edit*
    <input type>> =type [ =id ] [ =name ] bi =value input/> ;

: render-error ( message -- )
    <span "error" =class span> write </span> ;

TUPLE: hidden < field ;

: hidden ( -- renderer ) T{ hidden f "hidden" } ; inline

M: hidden render-view* 2drop ;

! Component protocol
SYMBOL: components

TUPLE: component id required default renderer ;

: component ( name -- component )
    dup components get at
    [ ] [ "No such component: " prepend throw ] ?if ;

GENERIC: init ( component -- component )

M: component init ;

GENERIC: validate* ( value component -- result )
GENERIC: component-string ( value component -- string )

SYMBOL: values

: value values get at ;

: set-value values get set-at ;

: blank-values H{ } clone values set ;

: from-tuple <mirror> values set ;

: values-tuple values get mirror-object ;

: render-view-or-summary ( component -- value renderer )
    [ id>> value ] [ component-string ] [ renderer>> ] tri ;

: render-view ( component -- )
    render-view-or-summary render-view* ;

: render-summary ( component -- )
    render-view-or-summary render-summary* ;

<PRIVATE

: render-edit-string ( string component -- )
    [ id>> ] [ renderer>> ] bi render-edit* ;

: render-edit-error ( component -- )
    [ id>> value ] keep
    [ [ value>> ] dip render-edit-string ]
    [ drop reason>> render-error ] 2bi ;

: value-or-default ( component -- value )
    [ id>> value ] [ default>> ] bi or ;

: render-edit-value ( component -- )
    [ value-or-default ]
    [ component-string ]
    [ render-edit-string ]
    tri ;

PRIVATE>

: render-edit ( component -- )
    dup id>> value validation-error?
    [ render-edit-error ] [ render-edit-value ] if ;

: validate ( value component -- result )
    '[
        ,
        over empty? [
            [ default>> [ v-default ] when* ]
            [ required>> [ v-required ] when ]
            bi
        ] [ validate* ] if
    ] with-validator ;

: new-component ( id class renderer -- component )
    swap new
        swap >>renderer
        swap >>id
        init ; inline

! String input fields
TUPLE: string < component one-line min-length max-length ;

: new-string ( id class -- component )
    "text" <field> new-component
        t >>one-line ; inline

: <string> ( id -- component )
    string new-string ;

M: string validate*
    [   one-line>> [ v-one-line   ] when  ]
    [ min-length>> [ v-min-length ] when* ]
    [ max-length>> [ v-max-length ] when* ]
    tri ;

M: string component-string
    drop ;

! Username fields
TUPLE: username < string ;

M: username init
    2 >>min-length
    20 >>max-length ;

: <username> ( id -- component )
    username new-string ;

M: username validate*
    call-next-method v-one-word ;

! E-mail fields
TUPLE: email < string ;

: <email> ( id -- component )
    email new-string
        5 >>min-length
        60 >>max-length ;

M: email validate*
    call-next-method dup empty? [ v-email ] unless ;

! URL fields
TUPLE: url < string ;

: <url> ( id -- component )
    url new-string
        5 >>min-length
        60 >>max-length ;

M: url validate*
    call-next-method dup empty? [ v-url ] unless ;

! Don't send passwords back to the user
TUPLE: password-renderer < field ;

: password-renderer T{ password-renderer f "password" } ;

: blank-password >r >r drop "" r> r> ;

M: password-renderer render-edit*
    blank-password call-next-method ;

! Password fields
TUPLE: password < string ;

M: password init
    6 >>min-length
    60 >>max-length ;

: <password> ( id -- component )
    password new-string
        password-renderer >>renderer ;

M: password validate*
    call-next-method v-one-word ;

! Number fields
TUPLE: number < string min-value max-value ;

: <number> ( id -- component )
    number new-string ;

M: number validate*
    [ v-number ] [
        [ min-value>> [ v-min-value ] when* ]
        [ max-value>> [ v-max-value ] when* ]
        bi
    ] bi* ;

M: number component-string
    drop dup [ number>string ] when ;

! Integer fields
TUPLE: integer < number ;

: <integer> ( id -- component )
    integer new-string ;

M: integer validate*
    call-next-method v-integer ;

! Simple captchas
TUPLE: captcha < string ;

: <captcha> ( id -- component )
    captcha new-string ;

M: captcha validate*
    drop v-captcha ;

! Text areas
TUPLE: text-renderer rows cols ;

: new-text-renderer ( class -- renderer )
    new
        60 >>cols
        20 >>rows ;

: <text-renderer> ( -- renderer )
    text-renderer new-text-renderer ;

M: text-renderer render-view*
    drop write ;

M: text-renderer render-edit*
    <textarea
        [ rows>> [ number>string =rows ] when* ]
        [ cols>> [ number>string =cols ] when* ] bi
        [ =id   ]
        [ =name ] bi
    textarea>
        write
    </textarea> ;

TUPLE: text < string ;

: new-text ( id class -- component )
    new-string
        f >>one-line
        <text-renderer> >>renderer ;

: <text> ( id -- component )
    text new-text ;

! HTML text component
TUPLE: html-text-renderer < text-renderer ;

: <html-text-renderer> ( -- renderer )
    html-text-renderer new-text-renderer ;

M: html-text-renderer render-view*
    drop write ;

TUPLE: html-text < text ;

: <html-text> ( id -- component )
    html-text new-text
        <html-text-renderer> >>renderer ;

! Date component
TUPLE: date < string ;

: <date> ( id -- component )
    date new-string ;

M: date component-string
    drop timestamp>string ;

! List components
SYMBOL: +plain+
SYMBOL: +ordered+
SYMBOL: +unordered+

TUPLE: list-renderer component type ;

C: <list-renderer> list-renderer

: render-plain-list ( seq quot component -- )
    swap '[ , @ ] each ; inline

: render-ordered-list ( seq quot component -- )
    swap <ol> '[ <li> , @ </li> ] each </ol> ; inline

: render-unordered-list ( seq quot component -- )
    swap <ul> '[ <li> , @ </li> ] each </ul> ; inline

: render-list ( value renderer quot -- )
    swap [ component>> ] [ type>> ] bi {
        { +plain+     [ render-plain-list ] }
        { +ordered+   [ render-ordered-list ] }
        { +unordered+ [ render-unordered-list ] }
    } case ; inline

M: list-renderer render-view*
    [ render-view* ] render-list ;

M: list-renderer render-summary*
    [ render-summary* ] render-list ;

TUPLE: list < component ;

: <list> ( id component type -- list )
    <list-renderer> list swap new-component ;

M: list component-string drop ;
