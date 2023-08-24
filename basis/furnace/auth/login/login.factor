! Copyright (c) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar furnace.actions furnace.asides
furnace.auth furnace.auth.login.permits furnace.conversations
furnace.redirection furnace.utilities html.forms http
http.server.dispatchers kernel logging math.parser namespaces
sequences urls validators ;
IN: furnace.auth.login

SYMBOL: permit-id

: permit-id-key ( realm -- string )
    bytes>hex-string "__p_" prepend ;

: client-permit-id ( realm -- id/f )
    permit-id-key client-state dup [ string>number ] when ;

TUPLE: login-realm < realm timeout domain ;

M: login-realm init-realm
    name>> client-permit-id permit-id set ;

M: login-realm logged-in-username
    drop permit-id get dup [ get-permit-uid ] when ;

M: login-realm modify-form
    drop permit-id get realm get name>> permit-id-key hidden-form-field ;

: <permit-cookie> ( -- cookie )
    permit-id get realm get name>> permit-id-key <cookie>
        "$login-realm" resolve-base-path >>path
        realm get
        [ domain>> >>domain ]
        [ secure>> >>secure ]
        bi ;

: put-permit-cookie ( response -- response' )
    <permit-cookie> put-cookie ;

\ put-permit-cookie DEBUG add-input-logging

: successful-login ( user -- response )
    [ username>> make-permit permit-id set ] [ init-user ] bi
    URL" $realm" end-aside
    put-permit-cookie ;

\ successful-login DEBUG add-input-logging

: logout ( -- response )
    permit-id get [ delete-permit ] when*
    URL" $realm" end-aside ;

<PRIVATE

SYMBOL: description
SYMBOL: capabilities

PRIVATE>

CONSTANT: flashed-variables { description capabilities }

: login-failed ( -- * )
    "invalid username or password" validation-error
    validation-failed ;

: <login-action> ( -- action )
    <page-action>
        [
            description cget "description" set-value
            capabilities cget words>strings "capabilities" set-value
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
        ] >>submit
    <auth-boilerplate>
    <secure-realm-only> ;

: <logout-action> ( -- action )
    <action>
        [ logout ] >>submit ;

M: login-realm login-required*
    begin-conversation
    [ description cset ] [ capabilities cset ] [ secure>> ] tri*
    [
        url get >secure-url begin-aside
        URL" $realm/login" >secure-url <continue-conversation>
    ] [
        url get begin-aside
        URL" $realm/login" <continue-conversation>
    ] if ;

M: login-realm user-registered
    drop successful-login ;

: <login-realm> ( responder name -- realm )
    login-realm new-realm
        <login-action> "login" add-responder
        <logout-action> "logout" add-responder
        20 minutes >>timeout ;
