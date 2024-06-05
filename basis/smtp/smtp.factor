! Copyright (C) 2007, 2009 Elie CHAFTARI, Dirk Vleugels,
! Slava Pestov, Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs base64 calendar calendar.format
classes combinators debugger io io.crlf io.encodings
io.encodings.ascii io.encodings.binary io.encodings.iana
io.encodings.string io.encodings.utf8 io.sockets
io.sockets.secure io.timeouts kernel logging make math.order
math.parser namespaces prettyprint random sequences sets
splitting strings words ;
IN: smtp

TUPLE: smtp-config domain server tls? { read-timeout duration } auth ;

SINGLETON: no-auth

TUPLE: plain-auth username password ;
C: <plain-auth> plain-auth

TUPLE: login-auth username password ;
C: <login-auth> login-auth

: <smtp-config> ( -- smtp-config )
    smtp-config new ; inline

: default-smtp-config ( -- smtp-config )
    <smtp-config>
        "localhost" 25 <inet> >>server
        1 minutes >>read-timeout
        no-auth >>auth ; inline

LOG: log-smtp-connection NOTICE

: with-smtp-connection ( quot -- )
    smtp-config get server>>
    dup log-smtp-connection
    ascii [
        smtp-config get
        [ [ host-name or ] change-domain drop ]
        [ read-timeout>> timeouts ] bi
        call
    ] with-client ; inline

: with-smtp-config ( quot -- )
    [ \ smtp-config get-global clone \ smtp-config ] dip
    '[ _ with-smtp-connection ] with-variable ; inline

TUPLE: email
    { from string }
    { to array }
    { cc array }
    { bcc array }
    { subject string }
    { content-type string initial: "text/plain" }
    { encoding word initial: utf8 }
    { body string } ;

: <email> ( -- email ) email new ; inline

<PRIVATE

: command ( string -- ) write crlf flush ;

\ command DEBUG add-input-logging

: helo ( -- ) "EHLO " host-name append command ;

: start-tls ( -- ) "STARTTLS" command ;

ERROR: bad-email-address email ;

: validate-address ( string -- string' )
    ! Make sure we send funky stuff to the server by accident.
    dup "\r\n>" intersects?
    [ bad-email-address ] when ;

: mail-from ( fromaddr -- )
    validate-address
    "MAIL FROM:<" ">" surround command ;

: rcpt-to ( to -- )
    validate-address
    "RCPT TO:<" ">" surround command ;

: data ( -- )
    "DATA" command ;

: send-body ( email -- )
    binary encode-output
    [ body>> ] [ encoding>> ] bi encode >base64-lines write
    ascii encode-output crlf
    "." command ;

: quit ( -- )
    "QUIT" command ;

LOG: smtp-response DEBUG

: multiline? ( response -- ? )
    3 swap ?nth CHAR: - = ;

: (receive-response) ( -- )
    read-crlf
    [ , ]
    [ smtp-response ]
    [ multiline? [ (receive-response) ] when ]
    tri ;

TUPLE: response code messages ;

: <response> ( lines -- response )
    [ first 3 head string>number ] keep response boa ;

: receive-response ( -- response )
    [ (receive-response) ] { } make <response> ;

ERROR: smtp-error response ;

M: smtp-error error.
    "SMTP error (" write dup class-of pprint ")" print
    response>> messages>> [ print ] each ;

ERROR: smtp-server-busy < smtp-error ;
ERROR: smtp-syntax-error < smtp-error ;
ERROR: smtp-command-not-implemented < smtp-error ;
ERROR: smtp-bad-authentication < smtp-error ;
ERROR: smtp-mailbox-unavailable < smtp-error ;
ERROR: smtp-user-not-local < smtp-error ;
ERROR: smtp-exceeded-storage-allocation < smtp-error ;
ERROR: smtp-bad-mailbox-name < smtp-error ;
ERROR: smtp-transaction-failed < smtp-error ;

: check-response ( response -- )
    dup code>> {
        { [ dup { 220 235 250 221 334 354 } member? ] [ 2drop ] }
        { [ dup 400 499 between? ] [ drop smtp-server-busy ] }
        { [ dup 500 = ] [ drop smtp-syntax-error ] }
        { [ dup 501 = ] [ drop smtp-command-not-implemented ] }
        { [ dup 500 509 between? ] [ drop smtp-syntax-error ] }
        { [ dup 530 539 between? ] [ drop smtp-bad-authentication ] }
        { [ dup 550 = ] [ drop smtp-mailbox-unavailable ] }
        { [ dup 551 = ] [ drop smtp-user-not-local ] }
        { [ dup 552 = ] [ drop smtp-exceeded-storage-allocation ] }
        { [ dup 553 = ] [ drop smtp-bad-mailbox-name ] }
        { [ dup 554 = ] [ drop smtp-transaction-failed ] }
        [ drop smtp-error ]
    } cond ;

: get-ok ( -- ) receive-response check-response ;

GENERIC: send-auth ( auth -- )

M: no-auth send-auth drop ;

: >smtp-base64 ( str -- str' )
    utf8 encode >base64 >string ;

: plain-auth-string ( username password -- string )
    [ "\0" prepend ] bi@ append >smtp-base64 ;

M: plain-auth send-auth
    [ username>> ] [ password>> ] bi plain-auth-string
    "AUTH PLAIN " prepend command get-ok ;

M: login-auth send-auth
    "AUTH LOGIN" command get-ok
    [ username>> >smtp-base64 command get-ok ]
    [ password>> >smtp-base64 command get-ok ] bi ;

: auth ( -- ) smtp-config get auth>> send-auth ;

: encode-header ( string -- string' )
    dup aux>> [
        utf8 encode >base64
        "=?utf-8?B?" "?=" surround
    ] when ;

ERROR: invalid-header-string string ;

: validate-header ( string -- string' )
    dup "\r\n" intersects?
    [ invalid-header-string ] when ;

: write-header ( key value -- )
    [ validate-header write ]
    [ ": " write validate-header encode-header write ] bi* crlf ;

: write-headers ( assoc -- )
    [ write-header ] assoc-each ;

: message-id ( -- string )
    [
        "<" %
        64 random-bits #
        "-" %
        now timestamp>micros #
        "@" %
        smtp-config get domain>> [ host-name ] unless* %
        ">" %
    ] "" make ;

: extract-email ( recepient -- email )
    ! This could be much smarter.
    " " split1-last or* "<" ?head drop ">" ?tail drop ;

: email-content-type ( email -- content-type )
    [ content-type>> ] [ encoding>> encoding>name ] bi "; charset=" glue ;

: email>headers ( email -- assoc )
    [
        now timestamp>rfc822 "Date" ,,
        message-id "Message-Id" ,,
        "1.0" "MIME-Version" ,,
        "base64" "Content-Transfer-Encoding" ,,
        {
            [ from>> "From" ,, ]
            [ to>> ", " join "To" ,, ]
            [ cc>> ", " join [ "Cc" ,, ] unless-empty ]
            [ subject>> "Subject" ,, ]
            [ email-content-type "Content-Type" ,, ]
        } cleave
    ] H{ } make ;

: (send-email) ( headers email -- )
    [
        get-ok
        helo get-ok
        smtp-config get tls?>> [
            start-tls get-ok send-secure-handshake
            helo get-ok
        ] when
        auth
        dup from>> extract-email mail-from get-ok
        dup to>> [ extract-email rcpt-to get-ok ] each
        dup cc>> [ extract-email rcpt-to get-ok ] each
        dup bcc>> [ extract-email rcpt-to get-ok ] each
        data get-ok
        swap write-headers
        crlf
        send-body get-ok
        quit get-ok
    ] with-smtp-connection ;

PRIVATE>

: send-email ( email -- )
    [ email>headers ] keep (send-email) ;
