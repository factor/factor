! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors new-slots quotations assocs kernel splitting
base64 html.elements io combinators http.server
http.server.auth.providers http.server.actions
http.server.sessions http.server.templating.fhtml http sequences
io.files namespaces ;
IN: http.server.auth.login

TUPLE: login-auth responder provider ;

C: (login-auth) login-auth

SYMBOL: logged-in?
SYMBOL: provider
SYMBOL: post-login-url

: login-page ( -- response )
    "text/html" <content> [
        "extra/http/server/auth/login/login.fhtml"
        resource-path run-template-file
    ] >>body ;

: <login-action>
    <action>
        [ login-page ] >>get

        {
            { "name" [ ] }
            { "password" [ ] }
        } >>post-params
        [
            "password" get
            "name" get
            provider sget check-login [
                t logged-in? sset
                post-login-url sget <permanent-redirect>
            ] [
                login-page
            ] if
        ] >>post ;

: <logout-action>
    <action>
        [
            f logged-in? sset
            request get "login" <permanent-redirect>
        ] >>post ;

M: login-auth call-responder ( request path responder -- response )
    logged-in? sget
    [ responder>> call-responder ] [
        pick method>> "GET" = [
            nip
            provider>> provider sset
            dup request-url post-login-url sset
            "login" f session-link <permanent-redirect>
        ] [
            3drop <400>
        ] if
    ] if ;

: <login-auth> ( responder provider -- auth )
        (login-auth)
        <dispatcher>
            swap >>default
            <login-action> "login" add-responder
            <logout-action> "logout" add-responder
    <cookie-sessions> ;
