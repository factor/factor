! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces io math.parser assocs classes
classes.tuple words arrays sequences splitting mirrors
hashtables combinators continuations math strings inspector
fry locals calendar calendar.format xml.entities
validators urls present
xmode.code2html lcs.diff2html farkup
html.elements html.streams html.forms ;
IN: html.components

GENERIC: render* ( value name render -- )

: render ( name renderer -- )
    prepare-value
    [
        dup validation-error?
        [ [ message>> ] [ value>> ] bi ]
        [ f swap ]
        if
    ] 2dip
    render*
    [ render-error ] when* ;

<PRIVATE

: render-input ( value name type -- )
    <input =type =name present =value input/> ;

PRIVATE>

SINGLETON: label

M: label render* 2drop present escape-string write ;

SINGLETON: hidden

M: hidden render* drop "hidden" render-input ;

: render-field ( value name size type -- )
    <input
        =type
        [ present =size ] when*
        =name
        present =value
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
        [ rows>> [ present =rows ] when* ]
        [ cols>> [ present =cols ] when* ] bi
        =name
    textarea>
        present escape-string write
    </textarea> ;

! Choice
TUPLE: choice size multiple choices ;

: <choice> ( -- choice )
    choice new ;

: render-option ( text selected? -- )
    <option [ "true" =selected ] when option>
        present escape-string write
    </option> ;

: render-options ( options selected -- )
    '[ dup , member? render-option ] each ;

M: choice render*
    <select
        swap =name
        dup size>> [ present =size ] when*
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
        swap [ "true" =checked ] when
    input>
        label>> escape-string write
    </input> ;

! Link components
GENERIC: link-title ( obj -- string )
GENERIC: link-href ( obj -- url )

M: string link-title ;
M: string link-href ;

M: url link-title ;
M: url link-href ;

SINGLETON: link

M: link render*
    2drop
    <a dup link-href =href a>
        link-title present escape-string write
    </a> ;

! XMode code component
TUPLE: code mode ;

: <code> ( -- code )
    code new ;

M: code render*
    [ string-lines ] [ drop ] [ mode>> value ] tri* htmlize-lines ;

! Farkup component
TUPLE: farkup no-follow disable-images ;

: string>boolean ( string -- boolean )
    {
        { "true" [ t ] }
        { "false" [ f ] }
    } case ;

M: farkup render*
    [
        [ no-follow>> [ string>boolean link-no-follow? set ] when* ]
        [ disable-images>> [ string>boolean disable-images? set ] when* ] bi
        drop string-lines "\n" join convert-farkup write
    ] with-scope ;

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
