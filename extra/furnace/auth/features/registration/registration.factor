! Copyright (c) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces validators html.forms urls
http.server.dispatchers
furnace furnace.auth furnace.auth.providers furnace.actions ;
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

            URL" $realm" <redirect>
        ] >>submit ;

: allow-registration ( login -- login )
    <register-action> <auth-boilerplate> "register" add-responder ;

: allow-registration? ( -- ? )
    realm get responders>> "register" swap key? ;
