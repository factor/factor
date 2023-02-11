! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces combinators words
assocs db.tuples arrays splitting strings validators urls fry
html.forms
html.components
furnace
furnace.boilerplate
furnace.auth.providers
furnace.auth.providers.db
furnace.auth.login
furnace.auth
furnace.actions
furnace.redirection
furnace.utilities
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

: validate-capabilities ( -- )
    "capabilities" value
    [ [ param empty? not ] keep set-value ] each ;

: selected-capabilities ( -- seq )
    "capabilities" value [ value ] filter strings>words ;

: validate-user ( -- )
    {
        { "username" [ v-username ] }
        { "realname" [ [ v-one-line ] v-optional ] }
        { "email" [ [ v-email ] v-optional ] }
    } validate-params ;

: <new-user-action> ( -- action )
    <page-action>
        [
            "username" param <user> from-object
            init-capabilities
        ] >>init

        { user-admin "new-user" } >>template

        [
            init-capabilities
            validate-capabilities

            validate-user

            {
                { "new-password" [ v-password ] }
                { "verify-password" [ v-password ] }
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

: select-capabilities ( seq -- )
    [ t swap word>string set-value ] each ;

: <edit-user-action> ( -- action )
    <page-action>
        [
            validate-username

            "username" value <user> select-tuple
            [ from-object ] [ capabilities>> select-capabilities ] bi

            init-capabilities
        ] >>init

        { user-admin "edit-user" } >>template

        [
            "username" value <user> select-tuple
            [ from-object ] [ capabilities>> select-capabilities ] bi

            init-capabilities
            validate-capabilities

            validate-user

            {
                { "new-password" [ [ v-password ] v-optional ] }
                { "verify-password" [ [ v-password ] v-optional ] }
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
            "username" value <user> delete-tuples
            URL" $user-admin" <redirect>
        ] >>submit ;

SYMBOL: can-administer-users?

can-administer-users? define-capability

: <user-admin> ( -- responder )
    user-admin new-dispatcher
        <user-list-action> "" add-responder
        <new-user-action> "new" add-responder
        <edit-user-action> "edit" add-responder
        <delete-user-action> "delete" add-responder
    <boilerplate>
        { user-admin "user-admin" } >>template
    <protected>
        "administer users" >>description
        { can-administer-users? } >>capabilities ;

: give-capability ( username capability -- )
    [ <user> select-tuple ] dip
    '[ _ suffix ] change-capabilities
    update-tuple ;

: make-admin ( username -- )
    can-administer-users? give-capability ;
