! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces combinators words
assocs db.tuples arrays splitting strings validators urls
html.elements
html.components
furnace
furnace.boilerplate
furnace.auth.providers
furnace.auth.providers.db
furnace.auth.login
furnace.auth
furnace.sessions
furnace.actions
http.server
http.server.dispatchers ;
IN: webapps.user-admin

TUPLE: user-admin < dispatcher ;

: <user-list-action> ( -- action )
    <page-action>
        [ f <user> select-tuples "users" set-value ] >>init
        { user-admin "user-list" } >>template ;

: init-capabilities ( -- )
    capabilities get words>strings "capabilities" set-value ;

: selected-capabilities ( -- seq )
    "capabilities" value
    [ param empty? not ] filter
    [ string>word ] map ;

: <new-user-action> ( -- action )
    <page-action>
        [
            "username" param <user> from-object
            init-capabilities
        ] >>init

        { user-admin "new-user" } >>template

        [
            init-capabilities

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
                selected-capabilities >>capabilities

            insert-tuple

            URL" $user-admin" <redirect>
        ] >>submit ;

: validate-username ( -- )
    { { "username" [ v-username ] } } validate-params ;

: <edit-user-action> ( -- action )
    <page-action>
        [
            validate-username

            "username" value <user> select-tuple
            [ from-object ]
            [ capabilities>> [ "true" swap word>string set-value ] each ] bi

            capabilities get words>strings "capabilities" set-value
        ] >>init

        { user-admin "edit-user" } >>template

        [
            init-capabilities

            {
                { "username" [ v-username ] }
                { "realname" [ v-one-line ] }
                { "new-password" [ [ v-password ] v-optional ] }
                { "verify-password" [ [ v-password ] v-optional ] }
                { "email" [ [ v-email ] v-optional ] }
            } validate-params

            "new-password" "verify-password"
            [ value empty? not ] either? [
                same-password-twice
            ] when
        ] >>validate

        [
            "username" value <user> select-tuple
                "realname" value >>realname
                "email" value >>email
                selected-capabilities >>capabilities

            "new-password" value empty? [
                "new-password" value >>encoded-password
            ] unless

            update-tuple

            URL" $user-admin" <redirect>
        ] >>submit ;

: <delete-user-action> ( -- action )
    <action>
        [
            validate-username

            [ <user> select-tuple 1 >>deleted update-tuple ]
            [ logout-all-sessions ]
            bi

            URL" $user-admin" <redirect>
        ] >>submit ;

SYMBOL: can-administer-users?

can-administer-users? define-capability

: <user-admin> ( -- responder )
    user-admin new-dispatcher
        <user-list-action> "list" add-main-responder
        <new-user-action> "new" add-responder
        <edit-user-action> "edit" add-responder
        <delete-user-action> "delete" add-responder
    <boilerplate>
        { user-admin "user-admin" } >>template
    <protected>
        "administer users" >>description
        { can-administer-users? } >>capabilities ;

: make-admin ( username -- )
    <user>
    select-tuple
    [ can-administer-users? suffix ] change-capabilities
    update-tuple ;
