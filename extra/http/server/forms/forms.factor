USING: kernel accessors assocs namespaces io.files fry
http.server.actions
http.server.components
http.server.validators
http.server.templating.fhtml ;
IN: http.server.forms

TUPLE: form < component view-template edit-template components ;

M: form init V{ } clone >>components ;

: <form> ( id -- form )
    form f new-component ;

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
