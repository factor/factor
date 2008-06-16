! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces validators urls
html.forms
http.server.dispatchers
furnace.auth
furnace.flash
furnace.asides
furnace.actions
furnace.sessions
furnace.utilities ;
IN: furnace.auth.login

TUPLE: login-realm < realm ;

: set-uid ( username -- )
    session get [ (>>uid) ] [ (session-changed) ] bi ;

: successful-login ( user -- response )
    username>> set-uid URL" $realm" end-aside ;

: logout ( -- ) f set-uid ;

SYMBOL: description
SYMBOL: capabilities

: flashed-variables { description capabilities } ;

: login-failed ( -- * )
    "invalid username or password" validation-error
    validation-failed ;

: <login-action> ( -- action )
    <page-action>
        [
            flashed-variables restore-flash
            description get "description" set-value
            capabilities get words>strings "capabilities" set-value
        ] >>init

        { login-realm "login" } >>template

        [
            {
                { "username" [ v-required ] }
                { "password" [ v-required ] }
            } validate-params

            "password" value
            "username" value check-login
            [ successful-login ] [ login-failed ] if*
        ] >>submit ;

: <logout-action> ( -- action )
    <action>
        [ logout URL" $login-realm" end-aside ] >>submit ;

M: login-realm login-required*
    drop
    begin-aside
    protected get description>> description set
    protected get capabilities>> capabilities set
    URL" $login/login" flashed-variables <flash-redirect> ;

M: login-realm logged-in-username
    drop session get uid>> ;

: <login-realm> ( responder name -- auth )
    login-realm new-realm
        <login-action> <auth-boilerplate> "login" add-responder
        <logout-action> "logout" add-responder ;
