! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors quotations assocs kernel splitting
combinators sequences namespaces hashtables sets
fry arrays threads qualified random validators
io
io.sockets
io.encodings.utf8
io.encodings.string
io.binary
continuations
destructors
checksums
checksums.sha2
validators
html.components
html.elements
urls
http
http.server
furnace.auth
furnace.auth.providers
furnace.auth.providers.db
furnace.actions
furnace.flows
furnace.sessions
furnace.boilerplate ;
QUALIFIED: smtp
IN: furnace.auth.login

TUPLE: login < dispatcher users checksum ;

: users ( -- provider )
    login get users>> ;

: encode-password ( string salt -- bytes )
    [ utf8 encode ] [ 4 >be ] bi* append
    login get checksum>> checksum-bytes ;

: >>encoded-password ( user string -- user )
    32 random-bits [ encode-password ] keep
    [ >>password ] [ >>salt ] bi* ; inline

: valid-login? ( password user -- ? )
    [ salt>> encode-password ] [ password>> ] bi = ;

: check-login ( password username -- user/f )
    users get-user dup [ [ valid-login? ] keep and ] [ 2drop f ] if ;

! Destructor
TUPLE: user-saver user ;

C: <user-saver> user-saver

M: user-saver dispose
    user>> dup changed?>> [ users update-user ] [ drop ] if ;

: save-user-after ( user -- )
    <user-saver> &dispose drop ;

! ! ! Login
: successful-login ( user -- response )
    username>> set-uid "$login" end-flow ;

: login-failed ( -- * )
    "invalid username or password" validation-error
    validation-failed ;

: <login-action> ( -- action )
    <page-action>
        "$login/login" >>template

        [
            {
                { "username" [ v-required ] }
                { "password" [ v-required ] }
            } validate-params

            "password" value
            "username" value check-login
            [ successful-login ] [ login-failed ] if*
        ] >>submit ;

! ! ! New user registration

: user-exists ( -- * )
    "username taken" validation-error
    validation-failed ;

: password-mismatch ( -- * )
    "passwords do not match" validation-error
    validation-failed ;

: same-password-twice ( -- )
    "new-password" value "verify-password" value =
    [ password-mismatch ] unless ;

: <register-action> ( -- action )
    <page-action>
        "$login/register" >>template

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

            login get init-user-profile

            successful-login
        ] >>submit ;

! ! ! Editing user profile

: <edit-profile-action> ( -- action )
    <page-action>
        [
            logged-in-user get
            [ username>> "username" set-value ]
            [ realname>> "realname" set-value ]
            [ email>> "email" set-value ]
            tri
        ] >>init

        "$login/edit-profile" >>template

        [
            uid "username" set-value

            {
                { "realname" [ [ v-one-line ] v-optional ] }
                { "password" [ ] }
                { "new-password" [ [ v-password ] v-optional ] }
                { "verify-password" [ [ v-password ] v-optional ] } 
                { "email" [ [ v-email ] v-optional ] }
            } validate-params

            { "password" "new-password" "verify-password" }
            [ value empty? not ] contains? [
                "password" value uid check-login
                [ "incorrect password" validation-error ] unless

                same-password-twice
            ] when
        ] >>validate

        [
            logged-in-user get

            "new-password" value dup empty?
            [ drop ] [ >>encoded-password ] if

            "realname" value >>realname
            "email" value >>email

            t >>changed?

            drop

            "$login" end-flow
        ] >>submit ;

! ! ! Password recovery

SYMBOL: lost-password-from

: current-host ( -- string )
    request get url>> host>> host-name or ;

: new-password-url ( user -- url )
    "recover-3"
    swap [
        [ username>> "username" set ]
        [ ticket>> "ticket" set ]
        bi
    ] H{ } make-assoc
    derive-url ;

: password-email ( user -- email )
    smtp:<email>
        [ "[ " % current-host % " ] password recovery" % ] "" make >>subject
        lost-password-from get >>from
        over email>> 1array >>to
        [
            "This e-mail was sent by the application server on " % current-host % "\n" %
            "because somebody, maybe you, clicked on a ``recover password'' link in the\n" %
            "login form, and requested a new password for the user named ``" %
            over username>> % "''.\n" %
            "\n" %
            "If you believe that this request was legitimate, you may click the below link in\n" %
            "your browser to set a new password for your account:\n" %
            "\n" %
            swap new-password-url %
            "\n\n" %
            "Love,\n" %
            "\n" %
            "  FactorBot\n" %
        ] "" make >>body ;

: send-password-email ( user -- )
    '[ , password-email smtp:send-email ]
    "E-mail send thread" spawn drop ;

: <recover-action-1> ( -- action )
    <page-action>
        "$login/recover-1" >>template

        [
            {
                { "username" [ v-username ] }
                { "email" [ v-email ] }
                { "captcha" [ v-captcha ] }
            } validate-params
        ] >>validate

        [
            "email" value "username" value
            users issue-ticket [
                send-password-email
            ] when*

            URL" $login/recover-2" <redirect>
        ] >>submit ;

: <recover-action-2> ( -- action )
    <page-action>
        "$login/recover-2" >>template ;

: <recover-action-3> ( -- action )
    <page-action>
        [
            {
                { "username" [ v-username ] }
                { "ticket" [ v-required ] }
            } validate-params
        ] >>init

        "$login/recover-3" >>template

        [
            {
                { "username" [ v-username ] }
                { "ticket" [ v-required ] }
                { "new-password" [ v-password ] }
                { "verify-password" [ v-password ] }
            } validate-params

            same-password-twice
        ] >>validate

        [
            "ticket" value
            "username" value
            users claim-ticket [
                "new-password" value >>encoded-password
                users update-user

                URL" $login/recover-4" <redirect>
            ] [
                <400>
            ] if*
        ] >>submit ;

: <recover-action-4> ( -- action )
    <page-action>
        "$login/recover-4" >>template ;

! ! ! Logout
: <logout-action> ( -- action )
    <action>
        [
            f set-uid
            "$login/login" end-flow
        ] >>submit ;

! ! ! Authentication logic

TUPLE: protected < filter-responder capabilities ;

C: <protected> protected

: show-login-page ( -- response )
    begin-flow
    URL" $login/login" <redirect> ;

: check-capabilities ( responder user -- ? )
    [ capabilities>> ] bi@ subset? ;

M: protected call-responder* ( path responder -- response )
    uid dup [
        users get-user 2dup check-capabilities [
            [ logged-in-user set ] [ save-user-after ] bi
            call-next-method
        ] [
            3drop show-login-page
        ] if
    ] [
        3drop show-login-page
    ] if ;

M: login call-responder* ( path responder -- response )
    dup login set
    call-next-method ;

: <login-boilerplate> ( responder -- responder' )
    <boilerplate>
        "$login/boilerplate" >>template ;

: <login> ( responder -- auth )
    login new-dispatcher
        swap >>default
        <login-action> <login-boilerplate> "login" add-responder
        <logout-action> <login-boilerplate> "logout" add-responder
        users-in-db >>users
        sha-256 >>checksum ;

! ! ! Configuration

: allow-edit-profile ( login -- login )
    <edit-profile-action> f <protected> <login-boilerplate>
        "edit-profile" add-responder ;

: allow-registration ( login -- login )
    <register-action> <login-boilerplate>
        "register" add-responder ;

: allow-password-recovery ( login -- login )
    <recover-action-1> <login-boilerplate>
        "recover-password" add-responder
    <recover-action-2> <login-boilerplate>
        "recover-2" add-responder
    <recover-action-3> <login-boilerplate>
        "recover-3" add-responder
    <recover-action-4> <login-boilerplate>
        "recover-4" add-responder ;

: allow-edit-profile? ( -- ? )
    login get responders>> "edit-profile" swap key? ;

: allow-registration? ( -- ? )
    login get responders>> "register" swap key? ;

: allow-password-recovery? ( -- ? )
    login get responders>> "recover-password" swap key? ;
