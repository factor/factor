! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces combinators words
assocs db.tuples arrays splitting strings validators
html.elements
html.components
html.templates.chloe
http.server.boilerplate
http.server.auth.providers
http.server.auth.providers.db
http.server.auth.login
http.server.auth
http.server.sessions
http.server.actions
http.server.crud
http.server ;
IN: webapps.user-admin

: admin-template ( name -- template )
    "resource:extra/webapps/user-admin/" swap ".xml" 3append <chloe> ;

: words>strings ( seq -- seq' )
    [ [ word-vocabulary ] [ drop ":" ] [ word-name ] tri 3append ] map ;

: strings>words ( seq -- seq' )
    [ ":" split1 swap lookup ] map ;

: <user-list-action> ( -- action )
    <action>
        [ f <user> select-tuples "users" set-value ] >>init
        [ "user-list" admin-template <html-content> ] >>display ;

: <new-user-action> ( -- action )
    <action>
        [
            "username" param <user> {
                [ username>> "username" set-value ]
                [ realname>> "realname" set-value ]
                [ email>> "email" set-value ]
                [ profile>> "profile" set-value ]
            } cleave

            capabilities get "all-capabilities" set-value
        ] >>init

        [ "new-user" admin-template <html-content> ] >>display

        [
            {
                { "username" [ v-username ] }
                { "realname" [ v-one-line ] }
                { "new-password" [ v-password ] }
                { "verify-password" [ v-password ] }
                { "email" [ [ v-email ] v-optional ] }
                { "capabilities" [ ] }
            } validate-params

            same-password-twice

            user new "username" value >>username select-tuple
            [ user-exists ] when
        ] >>validate

        [
            "username" value <user>
                "realname" value >>realname
                "email" value >>email
                "new-password" value >>encoded-password
                H{ } clone >>profile

            insert-tuple

            "$user-admin" f <standard-redirect>
        ] >>submit ;
    
: <edit-user-action> ( -- action )
    <action>
        [
            { { "username" [ v-username ] } } validate-params

            "username" value <user> select-tuple {
                [ username>> "username" set-value ]
                [ realname>> "realname" set-value ]
                [ email>> "email" set-value ]
                [ profile>> "profile" set-value ]
                [ capabilities>> words>strings "capabilities" set-value ]
            } cleave

            capabilities get "all-capabilities" set-value
        ] >>init

        [ "edit-user" admin-template <html-content> ] >>display

        [
            {
                { "username" [ v-username ] }
                { "realname" [ v-one-line ] }
                { "new-password" [ [ v-password ] v-optional ] }
                { "verify-password" [ [ v-password ] v-optional ] }
                { "email" [ [ v-email ] v-optional ] }
                { "capabilities" [ ] }
            } validate-params

            "new-password" "verify-password"
            [ value empty? ] both? [
                same-password-twice
            ] unless
        ] >>validate

        [
            "username" value <user> select-tuple
                "realname" value >>realname
                "email" value >>email

            "new-password" value empty? [ drop ] [
                "new-password" value >>encoded-password
            ] if

            "capabilities" value {
                { [ dup string? ] [ 1array ] }
                { [ dup array? ] [ ] }
            } cond strings>words >>capabilities

            update-tuple

            "$user-admin" f <standard-redirect>
        ] >>submit ;

: <delete-user-action> ( -- action )
    <action>
        [
            { { "username" [ v-username ] } } validate-params
            [ <user> select-tuple 1 >>deleted update-tuple ]
            [ logout-all-sessions ]
            bi

            "$user-admin" f <standard-redirect>
        ] >>submit ;

TUPLE: user-admin < dispatcher ;

SYMBOL: can-administer-users?

can-administer-users? define-capability

: <user-admin> ( -- responder )
    user-admin new-dispatcher
        <user-list-action> "" add-responder
        <new-user-action> "new" add-responder
        <edit-user-action> "edit" add-responder
        <delete-user-action> "delete" add-responder
    <boilerplate>
        "admin" admin-template >>template
    { can-administer-users? } <protected> ;

: make-admin ( username -- )
    <user>
    select-tuple
    [ can-administer-users? suffix ] change-capabilities
    update-tuple ;
