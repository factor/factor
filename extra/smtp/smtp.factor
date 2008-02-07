! Copyright (C) 2007, 2008 Elie CHAFTARI, Dirk Vleugels, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces io kernel io.logging io.sockets sequences
combinators sequences.lib splitting assocs strings math.parser
random system calendar ;

IN: smtp

SYMBOL: smtp-domain
SYMBOL: smtp-host       "localhost" smtp-host set-global
SYMBOL: smtp-port       25 smtp-port set-global
SYMBOL: read-timeout    60000 read-timeout set-global
SYMBOL: esmtp           t esmtp set-global

: log-smtp-connection ( host port -- )
    [
        "Establishing SMTP connection to " % swap % ":" % #
    ] "" make log-message ;

: with-smtp-connection ( quot -- )
    [
        smtp-host get smtp-port get
        2dup log-smtp-connection
        <inet> <client> [
            smtp-domain [ host-name or ] change
            read-timeout get stdio get set-timeout
            call
        ] with-stream
    ] with-log-stdio ; inline

: crlf "\r\n" write ;

: helo ( -- )
    esmtp get "EHLO " "HELO " ? write host-name write crlf ;

: validate-address ( string -- string' )
    #! Make sure we send funky stuff to the server by accident.
    dup [ "\r\n>" member? ] contains?
    [ "Bad e-mail address: " swap append throw ] when ;

: mail-from ( fromaddr -- )
    "MAIL FROM:<" write validate-address write ">" write crlf ;

: rcpt-to ( to -- )
    "RCPT TO:<" write validate-address write ">" write crlf ;

: data ( -- )
    "DATA" write crlf ;

: validate-message ( msg -- msg' )
    "." over member? [ "Message cannot contain . on a line by itself" throw ] when ;

: send-body ( body -- )
    validate-message
    [ write crlf ] each
    "." write crlf ;

: quit ( -- )
    "QUIT" write crlf ;

: log-response ( string -- ) "SMTP: " swap append log-message ;

: check-response ( response -- )
    {
        { [ dup "220" head? ] [ log-response ] }
        { [ dup "235" swap subseq? ] [ log-response ] }
        { [ dup "250" head? ] [ log-response ] }
        { [ dup "221" head? ] [ log-response ] }
        { [ dup "bye" head? ] [ log-response ] }
        { [ dup "4" head? ] [ "server busy" throw ] }
        { [ dup "354" head? ] [ log-response ] }
        { [ dup "50" head? ] [ log-response "syntax error" throw ] }
        { [ dup "53" head? ] [ log-response "invalid authentication data" throw ] }
        { [ dup "55" head? ] [ log-response "fatal error" throw ] }
        { [ t ] [ "unknown error" throw ] }
    } cond ;

: multiline? ( response -- boolean )
    ?fourth CHAR: - = ;

: process-multiline ( multiline -- response )
    >r readln r> 2dup " " append head? [
        drop dup log-response
    ] [
        swap check-response process-multiline
    ] if ;

: receive-response ( -- response )
    readln
    dup multiline? [ 3 head process-multiline ] when ;

: get-ok ( -- ) flush receive-response check-response ;

: send-raw-message ( body to from -- )
    [
        helo get-ok
        mail-from get-ok
        [ rcpt-to get-ok ] each
        data get-ok
        send-body get-ok
        quit get-ok
    ] with-smtp-connection ;

: validate-header ( string -- string' )
    dup [ "\r\n" member? ] contains?
    [ "Invalid header string: " swap append throw ] when ;

: prepare-header ( key value -- )
    swap
    validate-header %
    ": " %
    validate-header % ;

: prepare-headers ( assoc -- )
    [ [ prepare-header ] "" make , ] assoc-each ;

: extract-email ( recepient -- email )
    #! This could be much smarter.
    " " last-split1 [ ] [ ] ?if "<" ?head drop ">" ?tail drop ;

: message-id ( -- string )
    [
        "<" %
        2 big-random #
        "-" %
        millis #
        "@" %
        smtp-domain get %
        ">" %
    ] "" make ;

: simple-headers ( subject to from -- headers to from )
    [
        >r dup ", " join "To" set [ extract-email ] map r>
        dup "From" set extract-email
        rot "Subject" set
        now timestamp>rfc822-string "Date" set
        message-id "Message-Id" set
    ] { } make-assoc -rot ;

: prepare-message ( body headers -- body' )
    [
        prepare-headers
        " " ,
        dup string? [ string-lines ] when %
    ] { } make ;

: prepare-simple-message ( body subject to from -- body' to from )
    simple-headers >r >r prepare-message r> r> ;

: send-message ( body headers to from -- )
    >r >r prepare-message r> r> send-raw-message ;

: send-simple-message ( body subject to from -- )
    prepare-simple-message send-raw-message ;

! Dirk's old AUTH CRAM-MD5 code. I don't know anything about
! CRAM MD5, and the old code didn't work properly either, so here
! it is in case anyone wants to fix it later.
!
! check-response used to have this clause:
! { [ dup "334" head? ] [ " " split 1 swap nth base64> challenge set ] }
!
! and the rest of the code was as follows:
! : (cram-md5-auth) ( -- response )
!     swap challenge get 
!     string>md5-hmac hex-string 
!     " " swap append append 
!     >base64 ;
! 
! : cram-md5-auth ( key login  -- )
!     "AUTH CRAM-MD5\r\n" get-ok 
!     (cram-md5-auth) "\r\n" append get-ok ;
