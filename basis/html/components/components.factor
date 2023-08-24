! Copyright (C) 2008, 2010 Slava Pestov, Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators farkup html html.forms
html.streams inspector io kernel lcs.diff2html namespaces
present sequences splitting strings urls xml.data xml.syntax
xml.writer xmode.code2html ;
IN: html.components

GENERIC: render* ( value name renderer -- xml )

: render>xml ( name renderer -- xml )
    prepare-value
    [
        dup validation-error-state?
        [ [ message>> render-error ] [ value>> ] bi ]
        [ f swap ]
        if
    ] 2dip
    render*
    swap 2array ;

: render ( name renderer -- )
    render>xml write-xml ;

<PRIVATE

GENERIC: write-nested ( obj -- )

M: string write-nested write ;

M: sequence write-nested [ write-nested ] each ;

PRIVATE>

: render-string ( name renderer -- )
    render>xml write-nested ;

SINGLETON: label

M: label render*
    2drop present ;

SINGLETON: hidden

M: hidden render*
    drop [XML <input value=<-> name=<-> type="hidden"/> XML] ;

: render-field ( value name size type -- xml )
    [XML <input value=<-> name=<-> size=<-> type=<->/> XML] ;

TUPLE: field size ;

: <field> ( -- field )
    field new ;

M: field render*
    size>> "text" render-field ;

TUPLE: password size ;

: <password> ( -- password )
    password new ;

M: password render*
    ! Don't send passwords back to the user
    [ drop "" ] 2dip size>> "password" render-field ;

! Text areas
TUPLE: textarea rows cols ;

: <textarea> ( -- renderer )
    textarea new ;

M:: textarea render* ( value name area -- xml )
    area rows>> :> rows
    area cols>> :> cols
    [XML
         <textarea
            name=<-name->
            rows=<-rows->
            cols=<-cols->><-value-></textarea>
    XML] ;

! Choice
TUPLE: choice size multiple choices ;

: <choice> ( -- choice )
    choice new ;

: render-option ( text selected? -- xml )
    "selected" and swap
    [XML <option selected=<->><-></option> XML] ;

: render-options ( value choice -- xml )
    [ choices>> value ] [ multiple>> ] bi
    [ swap ] [ swap 1array ] if
    '[ dup _ member? render-option ] map ;

M:: choice render* ( value name choice -- xml )
    choice size>> :> size
    choice multiple>> "true" and :> multiple
    value choice render-options :> contents
    [XML <select
        name=<-name->
        size=<-size->
        multiple=<-multiple->><-contents-></select> XML] ;

! Checkboxes
TUPLE: checkbox label ;

: <checkbox> ( -- checkbox )
    checkbox new ;

M: checkbox render*
    [ "true" and ] [ ] [ label>> ] tri*
    [XML <input
        type="checkbox"
        checked=<-> name=<->><-></input> XML] ;

! Link components
GENERIC: link-title ( obj -- string )
GENERIC: link-href ( obj -- url )

M: string link-title ;
M: string link-href ;

M: url link-title ;
M: url link-href ;

TUPLE: simple-link title href ;

C: <simple-link> simple-link

M: simple-link link-title title>> ;
M: simple-link link-href href>> ;

TUPLE: link target ;

M: link render*
    nip swap
    [ target>> ] [ [ link-href ] [ link-title ] bi ] bi*
    [XML <a target=<-> href=<->><-></a> XML] ;

! XMode code component
TUPLE: code mode ;

: <code> ( -- code )
    code new ;

: ?split-lines ( str/f -- seq )
    [ { } ] [ split-lines ] if-empty ;

M: code render*
    [ ?split-lines ] [ drop ] [ mode>> value ] tri* htmlize-lines ;

! Farkup component
TUPLE: farkup no-follow disable-images parsed ;

: <farkup> ( -- farkup )
    farkup new ;

: string>boolean ( string -- boolean )
    {
        { "true" [ t ] }
        { "false" [ f ] }
        { f [ f ] }
    } case ;

M: farkup render*
    [
        nip
        [ no-follow>> [ string>boolean link-no-follow? set ] when* ]
        [ disable-images>> [ string>boolean disable-images? set ] when* ]
        [ parsed>> string>boolean [ (write-farkup) ] [ farkup>xml ] if ]
        tri
    ] with-scope ;

! Inspector component
SINGLETON: inspector

M: inspector render*
    2drop [ describe ] with-html-writer ;

! Diff component
SINGLETON: comparison

M: comparison render*
    2drop htmlize-diff ;

! HTML component
SINGLETON: html

M: html render* 2drop dup string? [ <unescaped> ] when ;

! XML component
SINGLETON: xml

M: xml render* 2drop ;
