! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces io math.parser assocs classes
classes.tuple words arrays sequences sequences.lib splitting
mirrors hashtables combinators continuations math strings
fry locals calendar calendar.format xml.entities validators
html.elements html.streams xmode.code2html farkup inspector
lcs.diff2html ;
IN: html.components

SYMBOL: values

: value values get at ;

: set-value values get set-at ;

: blank-values H{ } clone values set ;

: prepare-value ( name object -- value name object )
    [ [ value ] keep ] dip ; inline

: from-assoc ( assoc -- ) values get swap update ;

: from-tuple ( tuple -- ) <mirror> from-assoc ;

: deposit-values ( destination names -- )
    [ dup value ] H{ } map>assoc update ;

: deposit-slots ( destination names -- )
    [ <mirror> ] dip deposit-values ;

: with-each-index ( seq quot -- )
    '[
        [
            blank-values 1+ "index" set-value @
        ] with-scope
    ] each-index ; inline

: with-each-value ( seq quot -- )
    '[ "value" set-value @ ] with-each-index ; inline

: with-each-assoc ( seq quot -- )
    '[ from-assoc @ ] with-each-index ; inline

: with-each-tuple ( seq quot -- )
    '[ from-tuple @ ] with-each-index ; inline

: with-assoc-values ( assoc quot -- )
    '[ blank-values , from-assoc @ ] with-scope ; inline

: with-tuple-values ( assoc quot -- )
    '[ blank-values , from-tuple @ ] with-scope ; inline

: nest-values ( name quot -- )
    swap [
        [
            H{ } clone [ values set call ] keep
        ] with-scope
    ] dip set-value ; inline

: nest-tuple ( name quot -- )
    swap [
        [
            H{ } clone [ <mirror> values set call ] keep
        ] with-scope
    ] dip set-value ; inline

: object>string ( object -- string )
    {
        { [ dup real? ] [ number>string ] }
        { [ dup timestamp? ] [ timestamp>string ] }
        { [ dup string? ] [ ] }
        { [ dup word? ] [ word-name ] }
        { [ dup not ] [ drop "" ] }
    } cond ;

GENERIC: render* ( value name render -- )

: render ( name renderer -- )
    over named-validation-messages get at [
        [ value>> ] [ message>> ] bi
        [ -rot render* ] dip
        render-error
    ] [
        prepare-value render*
    ] if* ;

<PRIVATE

: render-input ( value name type -- )
    <input =type =name object>string =value input/> ;

PRIVATE>

SINGLETON: label

M: label render* 2drop object>string escape-string write ;

SINGLETON: hidden

M: hidden render* drop "hidden" render-input ;

: render-field ( value name size type -- )
    <input
        =type
        [ object>string =size ] when*
        =name
        object>string =value
    input/> ;

TUPLE: field size ;

: <field> ( -- field )
    field new ;

M: field render* size>> "text" render-field ;

TUPLE: password size ;

: <password> ( -- password )
    password new ;

M: password render*
    #! Don't send passwords back to the user
    [ drop "" ] 2dip size>> "password" render-field ;

! Text areas
TUPLE: textarea rows cols ;

: <textarea> ( -- renderer )
    textarea new ;

M: textarea render*
    <textarea
        [ rows>> [ object>string =rows ] when* ]
        [ cols>> [ object>string =cols ] when* ] bi
        =name
    textarea>
        object>string escape-string write
    </textarea> ;

! Choice
TUPLE: choice size multiple choices ;

: <choice> ( -- choice )
    choice new ;

: render-option ( text selected? -- )
    <option [ "true" =selected ] when option>
        object>string escape-string write
    </option> ;

: render-options ( options selected -- )
    '[ dup , member? render-option ] each ;

M: choice render*
    <select
        swap =name
        dup size>> [ object>string =size ] when*
        dup multiple>> [ "true" =multiple ] when
    select>
        [ choices>> value ] [ multiple>> ] bi
        [ swap ] [ swap 1array ] if
        render-options
    </select> ;

! Checkboxes
TUPLE: checkbox label ;

: <checkbox> ( -- checkbox )
    checkbox new ;

M: checkbox render*
    <input
        "checkbox" =type
        swap =name
        swap [ "true" =selected ] when
    input>
        label>> escape-string write
    </input> ;

! Link components
GENERIC: link-title ( obj -- string )
GENERIC: link-href ( obj -- url )

SINGLETON: link

M: link render*
    2drop
    <a dup link-href =href a>
        link-title object>string escape-string write
    </a> ;

! XMode code component
TUPLE: code mode ;

: <code> ( -- code )
    code new ;

M: code render*
    [ string-lines ] [ drop ] [ mode>> value ] tri* htmlize-lines ;

! Farkup component
SINGLETON: farkup

M: farkup render*
    2drop string-lines "\n" join convert-farkup write ;

! Inspector component
SINGLETON: inspector

M: inspector render*
    2drop [ describe ] with-html-stream ;

! Diff component
SINGLETON: comparison

M: comparison render*
    2drop htmlize-diff ;

! HTML component
SINGLETON: html

M: html render* 2drop write ;
