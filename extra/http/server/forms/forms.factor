! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs namespaces io.files sequences fry
http.server
http.server.actions
http.server.components
http.server.validators
http.server.templating ;
IN: http.server.forms

TUPLE: form < component
view-template edit-template summary-template
components ;

M: form init V{ } clone >>components ;

: <form> ( id -- form )
    form f new-component ;

: add-field ( form component -- form )
    dup id>> pick components>> set-at ;

: set-components ( form -- )
    components>> components set ;

: with-form ( form quot -- )
    [ [ set-components ] [ call ] bi* ] with-scope ; inline

: set-defaults ( form -- )
    [
        components get [
            swap values get [
                swap default>> or
            ] change-at
        ] assoc-each
    ] with-form ;

: <form-response> ( form template -- response )
    [ components>> components set ]
    [ "text/html" <content> swap >>body ]
    bi* ;

: view-form ( form -- response )
    dup view-template>> <form-response> ;

: edit-form ( form -- response )
    dup edit-template>> <form-response> ;

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

: render-form ( value form template -- )
    [
        [ from-tuple ]
        [ set-components ]
        [ call-template ]
        tri*
    ] with-scope ;

M: form render-summary*
    dup summary-template>> render-form ;

M: form render-view*
    dup view-template>> render-form ;

M: form render-edit*
    dup edit-template>> render-form ;
