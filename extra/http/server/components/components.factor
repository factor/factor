! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: new-slots html.elements http.server.validators
accessors namespaces kernel io farkup math.parser assocs
classes words tuples arrays sequences io.files
http.server.templating.fhtml splitting mirrors ;
IN: http.server.components

SYMBOL: components

TUPLE: component id ;

: component ( name -- component )
    dup components get at
    [ ] [ "No such component: " swap append throw ] ?if ;

GENERIC: validate* ( string component -- result )
GENERIC: render-view* ( value component -- )
GENERIC: render-edit* ( value component -- )
GENERIC: render-error* ( reason value component -- )

SYMBOL: values

: value values get at ;

: render-view ( component -- )
    dup id>> value swap render-view* ;

: render-error ( error -- )
    <span "error" =class span> write </span> ;

: render-edit ( component -- )
    dup id>> value dup validation-error? [
        dup reason>> swap value>> rot render-error*
    ] [
        swap render-edit*
    ] if ;

: <component> ( id string -- component )
    >r \ component construct-boa r> construct-delegate ; inline

TUPLE: string min max ;

: <string> ( id -- component ) string <component> ;

M: string validate*
    [ min>> v-min-length ] keep max>> v-max-length ;

M: string render-view*
    drop write ;

: render-input
    <input "text" =type id>> dup =id =name =value input/> ;

M: string render-edit*
    render-input ;

M: string render-error*
    render-input render-error ;

TUPLE: text ;

: <text> ( id -- component ) <string> text construct-delegate ;

: render-textarea
    <textarea id>> dup =id =name textarea> write </textarea> ;

M: text render-edit*
    render-textarea ;

M: text render-error*
    render-textarea render-error ;

TUPLE: farkup ;

: <farkup> ( id -- component ) <text> farkup construct-delegate ;

M: farkup render-view*
    drop string-lines "\n" join convert-farkup write ;

TUPLE: number min max ;

: <number> ( id -- component ) number <component> ;

M: number validate*
    >r v-number r> [ min>> v-min-value ] keep max>> v-max-value ;

M: number render-view*
    drop number>string write ;

M: number render-edit*
    >r number>string r> render-input ;

M: number render-error*
    render-input render-error ;

: with-components ( tuple components quot -- )
    [
        >r components set
        dup make-mirror values set
        tuple set
        r> call
    ] with-scope ; inline

TUPLE: form view-template edit-template components ;

: <form> ( id view-template edit-template -- form )
    V{ } clone form construct-boa
    swap \ component construct-boa
    over set-delegate ;

: add-field ( form component -- form )
    dup id>> pick components>> set-at ;

M: form render-view* ( value form -- )
    dup components>>
    swap view-template>>
    [ resource-path run-template-file ] curry
    with-components ;

M: form render-edit* ( value form -- )
    dup components>>
    swap edit-template>>
    [ resource-path run-template-file ] curry
    with-components ;
