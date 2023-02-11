! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs furnace.actions furnace.conversations
html.forms html.templates.chloe.compiler
html.templates.chloe.syntax http.client http.server
http.server.filters io.sockets json kernel namespaces urls
validators xml.syntax ;
IN: furnace.recaptcha

TUPLE: recaptcha < filter-responder domain secret-key site-key ;

SYMBOL: recaptcha-error

: <recaptcha> ( responder -- recaptcha )
    recaptcha new
        swap >>responder ;

M: recaptcha call-responder*
    dup recaptcha set
    responder>> call-responder ;

<PRIVATE

: render-recaptcha ( recaptcha -- xml )
    site-key>> [XML
        <script type="text/javascript"
           src="https://www.google.com/recaptcha/api.js" async="async" defer="defer">
        </script>

        <div class="g-recaptcha" data-sitekey=<->></div>
    XML] ;

: parse-recaptcha-response ( string -- valid? error )
    json> [ "success" of ] [ "error-codes" of ] bi ;

:: (validate-recaptcha) ( response recaptcha -- valid? error )
    recaptcha secret-key>> :> secret-key
    remote-address get host>> :> remote-ip
    H{
        { "response" response }
        { "secret" secret-key }
        { "remoteip" remote-ip }
    } URL" https://www.google.com/recaptcha/api/siteverify"
    http-post nip parse-recaptcha-response ;

: validate-recaptcha-params ( -- )
    {
        { "g-recaptcha-response" [ v-required ] }
    } validate-params ;

PRIVATE>

CHLOE: recaptcha drop [ recaptcha get render-recaptcha ] [xml-code] ;

: validate-recaptcha ( -- )
    begin-conversation
    validate-recaptcha-params

    "g-recaptcha-response" value
    recaptcha get
    (validate-recaptcha)
    recaptcha-error cset
    [ validation-failed ] unless ;
