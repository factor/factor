! Copyright (c) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs furnace.actions furnace.auth
furnace.auth.providers html.forms http.server.dispatchers kernel
namespaces validators ;
IN: furnace.auth.features.registration

: <register-action> ( -- action )
    <page-action>
        { realm "features/registration/register" } >>template

        [
            {
                { "username" [ v-username ] }
                { "realname" [ [ v-one-line ] v-optional ] }
                { "new-password" [ v-password ] }
                { "verify-password" [ v-password ] }
                { "email" [ [ v-email ] v-optional ] }
                { "captcha" [ v-captcha ] }
            } validate-params

            same-password-twice
        ] >>validate

        [
            "username" value <user>
                "realname" value >>realname
                "new-password" value >>encoded-password
                "email" value >>email
                H{ } clone >>profile

            users new-user [ user-exists ] unless*

            realm get init-user-profile
            realm get user-registered
        ] >>submit
    <auth-boilerplate>
    <secure-realm-only> ;

: allow-registration ( realm -- realm )
    <register-action> "register" add-responder ;

: allow-registration? ( -- ? )
    realm get responders>> "register" swap key? ;
