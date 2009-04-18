! Copyright (C) 2007, 2008 Elie CHAFTARI, Dirk Vleugels,
! Slava Pestov, Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays namespaces make io io.encodings.string io.encodings.utf8
io.encodings.iana io.timeouts io.sockets io.sockets.secure
io.encodings.ascii kernel logging sequences combinators splitting
assocs strings math.order math.parser random system calendar summary
calendar.format accessors sets hashtables base64 debugger classes
prettyprint io.crlf words ;
IN: smtp

SYMBOL: smtp-domain

SYMBOL: smtp-server
"localhost" 25 <inet> smtp-server set-global

SYMBOL: smtp-tls?

SYMBOL: smtp-read-timeout
1 minutes smtp-read-timeout set-global

SINGLETON: no-auth

TUPLE: plain-auth username password ;
C: <plain-auth> plain-auth

SYMBOL: smtp-auth
no-auth smtp-auth set-global

LOG: log-smtp-connection NOTICE ( addrspec -- )

: with-smtp-connection ( quot -- )
    smtp-server get
    dup log-smtp-connection
    ascii [
        smtp-domain [ host-name or ] change
        smtp-read-timeout get timeouts
        call
    ] with-client ; inline

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
    #! Make sure we send funky stuff to the server by accident.
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

ERROR: message-contains-dot message ;

M: message-contains-dot summary ( obj -- string )
    drop "Message cannot contain . on a line by itself" ;

: validate-message ( msg -- msg' )
    "." over member?
    [ message-contains-dot ] when ;

: send-body ( email -- )
    [ body>> ] [ encoding>> ] bi encode
    >base64-lines write crlf
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
    "SMTP error (" write dup class pprint ")" print
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
        { [ dup { 220 235 250 221 354 } member? ] [ 2drop ] }
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

: plain-auth-string ( username password -- string )
    [ "\0" prepend ] bi@ append utf8 encode >base64 ;

M: plain-auth send-auth
    [ username>> ] [ password>> ] bi plain-auth-string
    "AUTH PLAIN " prepend command get-ok ;

: auth ( -- ) smtp-auth get send-auth ;

: encode-header ( string -- string' )
    dup aux>> [
        "=?utf-8?B?"
        swap utf8 encode >base64
        "?=" 3append
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
        micros #
        "@" %
        smtp-domain get [ host-name ] unless* %
        ">" %
    ] "" make ;

: extract-email ( recepient -- email )
    ! This could be much smarter.
    " " split1-last swap or "<" ?head drop ">" ?tail drop ;

: email-content-type ( email -- content-type )
    [ content-type>> ] [ encoding>> encoding>name ] bi "; charset=" glue ;

: email>headers ( email -- assoc )
    [
        now timestamp>rfc822 "Date" set
        message-id "Message-Id" set
        "1.0" "MIME-Version" set
        "base64" "Content-Transfer-Encoding" set
        {
            [ from>> "From" set ]
            [ to>> ", " join "To" set ]
            [ cc>> ", " join [ "Cc" set ] unless-empty ]
            [ subject>> "Subject" set ]
            [ email-content-type "Content-Type" set ]
        } cleave
    ] { } make-assoc ;

: (send-email) ( headers email -- )
    [
        get-ok
        helo get-ok
        smtp-tls? get [ start-tls get-ok send-secure-handshake ] when
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
