! Copyright (c) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces sequences assocs
validators urls html.forms http.server.dispatchers
furnace.auth
furnace.asides
furnace.actions ;
IN: furnace.auth.features.edit-profile

: <edit-profile-action> ( -- action )
    <page-action>
        [
            logged-in-user get
            [ username>> "username" set-value ]
            [ realname>> "realname" set-value ]
            [ email>> "email" set-value ]
            tri
        ] >>init

        { realm "features/edit-profile/edit-profile" } >>template

        [
            username "username" set-value

            {
                { "realname" [ [ v-one-line ] v-optional ] }
                { "password" [ ] }
                { "new-password" [ [ v-password ] v-optional ] }
                { "verify-password" [ [ v-password ] v-optional ] }
                { "email" [ [ v-email ] v-optional ] }
            } validate-params

            { "password" "new-password" "verify-password" }
            [ value empty? not ] any? [
                "password" value username check-login
                [ "incorrect password" validation-error ] unless

                same-password-twice
            ] when
        ] >>validate

        [
            logged-in-user get

            "new-password" value
            [ >>encoded-password ] unless-empty

            "realname" value >>realname
            "email" value >>email

            t >>changed?

            drop

            URL" $realm" end-aside
        ] >>submit

    <protected>
        "edit your profile" >>description ;

: allow-edit-profile ( realm -- realm )
    <edit-profile-action> <auth-boilerplate> "edit-profile" add-responder ;

: allow-edit-profile? ( -- ? )
    realm get responders>> "edit-profile" swap key? ;
