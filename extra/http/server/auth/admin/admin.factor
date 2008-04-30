! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces combinators
locals db.tuples
http.server.templating.chloe
http.server.boilerplate
http.server.auth.providers
http.server.auth.providers.db
http.server.auth.login
http.server.forms
http.server.components.inspector
http.server.components
http.server.validators
http.server.actions
http.server.crud
http.server ;
IN: http.server.auth.admin

: admin-template ( name -- template )
    "resource:extra/http/server/auth/admin/" swap ".xml" 3append <chloe> ;

: <user-form> ( -- form )
    "user" <form>
        "user" admin-template >>edit-template
        "user-summary" admin-template >>summary-template
        "username" <string> add-field
        "realname" <string> add-field
        "new-password" <password> add-field
        "verify-password" <password> add-field
        "email" <email> add-field
        "profile" <inspector> add-field ;

: <user-list-form> ( -- form )
    "user-list" <form>
        "user-list" admin-template >>view-template
        "list" <user-form> +plain+ <list> add-field ;

:: <edit-user-action> ( form ctor next -- action )
    <action>
        { { "username" [ ] } } >>get-params

        [
            blank-values

            "username" get ctor call

            "username" get [ select-tuple ] when

            {
                [ username>> "username" set-value ]
                [ realname>> "realname" set-value ]
                [ email>> "email" set-value ]
                [ profile>> "profile" set-value ]
            } cleave
        ] >>init

        [ form edit-form ] >>display

        [
            blank-values

            form validate-form

            "username" value find-user
                "realname" value >>realname
                "email" value >>email

            { "new-password" "verify-password" }
            [ value empty? ] all? [
                same-password-twice
                "new-password" value >>password
            ] unless

            update-tuple

            next f <standard-redirect>
        ] >>submit ;

TUPLE: user-admin < dispatcher ;

:: <user-admin> ( -- responder )
    [let | ctor [ [ <user> ] ] |
        user-admin new-dispatcher
            <user-list-form> ctor <list-action> "" add-responder
            <user-form> ctor "$user-admin" <edit-user-action> "edit" add-responder
        <boilerplate>
            "admin" admin-template >>template
        <protected>
    ] ;
