! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.redirection html.forms
html.templates.chloe.compiler html.templates.chloe.syntax
http.client http.server http.server.filters io.sockets kernel
locals namespaces sequences splitting urls validators
xml.syntax furnace.conversations ;
IN: furnace.recaptcha

TUPLE: recaptcha < filter-responder domain public-key private-key ;

SYMBOL: recaptcha-error

: <recaptcha> ( responder -- recaptcha )
    recaptcha new
        swap >>responder ;

M: recaptcha call-responder*
    dup recaptcha set
    responder>> call-responder ;

<PRIVATE

: (render-recaptcha) ( url -- xml )
    dup
    [XML
        <script type="text/javascript"
           src=<->>
        </script>

        <noscript>
           <iframe src=<->
               height="300" width="500" frameborder="0"></iframe><br/>
           <textarea name="recaptcha_challenge_field" rows="3" cols="40">
           </textarea>
           <input type="hidden" name="recaptcha_response_field"
               value="manual_challenge"/>
        </noscript>
    XML] ;

: recaptcha-url ( secure? -- ? )
    "https" "http" ? "://www.google.com/recaptcha/api/challenge" append
    recaptcha-error cget [ "?error=" glue ] when* >url ;

: render-recaptcha ( -- xml )
    secure-connection? recaptcha-url
    recaptcha get public-key>> "k" set-query-param (render-recaptcha) ;

: parse-recaptcha-response ( string -- valid? error )
    "\n" split first2 [ "true" = ] dip ;

:: (validate-recaptcha) ( challenge response recaptcha -- valid? error )
    recaptcha private-key>> :> private-key
    remote-address get host>> :> remote-ip
    H{
        { "challenge" challenge }
        { "response" response }
        { "privatekey" private-key }
        { "remoteip" remote-ip }
    } URL" http://api-verify.recaptcha.net/verify"
    http-post nip parse-recaptcha-response ;

: validate-recaptcha-params ( -- )
    {
        { "recaptcha_challenge_field" [ v-required ] }
        { "recaptcha_response_field" [ v-required ] }
    } validate-params ;

PRIVATE>

CHLOE: recaptcha drop [ render-recaptcha ] [xml-code] ;

: validate-recaptcha ( -- )
    begin-conversation
    validate-recaptcha-params

    "recaptcha_challenge_field" value
    "recaptcha_response_field" value
    recaptcha get
    (validate-recaptcha)
    recaptcha-error cset
    [ validation-failed ] unless ;
