! Copyright (C) 2007, 2008 Elie CHAFTARI, Dirk Vleugels,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces io io.timeouts kernel logging io.sockets
sequences combinators sequences.lib splitting assocs strings
math.parser random system calendar io.encodings.ascii
calendar.format new-slots accessors ;
IN: smtp

SYMBOL: smtp-domain
SYMBOL: smtp-host       "localhost" smtp-host set-global
SYMBOL: smtp-port       25 smtp-port set-global
SYMBOL: read-timeout    1 minutes read-timeout set-global
SYMBOL: esmtp           t esmtp set-global

: log-smtp-connection ( host port -- ) 2drop ;

\ log-smtp-connection NOTICE add-input-logging

: with-smtp-connection ( quot -- )
    smtp-host get smtp-port get
    2dup log-smtp-connection
    <inet> ascii <client> [
        smtp-domain [ host-name or ] change
        read-timeout get stdio get set-timeout
        call
    ] with-stream ; inline

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
    string-lines
    validate-message
    [ write crlf ] each
    "." write crlf ;

: quit ( -- )
    "QUIT" write crlf ;

LOG: smtp-response DEBUG

: check-response ( response -- )
    {
        { [ dup "220" head? ] [ smtp-response ] }
        { [ dup "235" swap subseq? ] [ smtp-response ] }
        { [ dup "250" head? ] [ smtp-response ] }
        { [ dup "221" head? ] [ smtp-response ] }
        { [ dup "bye" head? ] [ smtp-response ] }
        { [ dup "4" head? ] [ "server busy" throw ] }
        { [ dup "354" head? ] [ smtp-response ] }
        { [ dup "50" head? ] [ smtp-response "syntax error" throw ] }
        { [ dup "53" head? ] [ smtp-response "invalid authentication data" throw ] }
        { [ dup "55" head? ] [ smtp-response "fatal error" throw ] }
        { [ t ] [ "unknown error" throw ] }
    } cond ;

: multiline? ( response -- boolean )
    ?fourth CHAR: - = ;

: process-multiline ( multiline -- response )
    >r readln r> 2dup " " append head? [
        drop dup smtp-response
    ] [
        swap check-response process-multiline
    ] if ;

: receive-response ( -- response )
    readln
    dup multiline? [ 3 head process-multiline ] when ;

: get-ok ( -- ) flush receive-response check-response ;

: validate-header ( string -- string' )
    dup [ "\r\n" member? ] contains?
    [ "Invalid header string: " swap append throw ] when ;

: write-header ( key value -- )
    swap
    validate-header write
    ": " write
    validate-header write
    crlf ;

: write-headers ( assoc -- )
    [ write-header ] assoc-each ;

TUPLE: email from to subject headers body ;

M: email clone
    (clone) [ clone ] change-headers ;

: (send) ( email -- )
    [
        helo get-ok
        dup from>> mail-from get-ok
        dup to>> [ rcpt-to get-ok ] each
        data get-ok
        dup headers>> write-headers
        crlf
        body>> send-body get-ok
        quit get-ok
    ] with-smtp-connection ;

: extract-email ( recepient -- email )
    #! This could be much smarter.
    " " last-split1 swap or "<" ?head drop ">" ?tail drop ;

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

: set-header ( email value key -- email )
    pick headers>> set-at ;

: prepare ( email -- email )
    clone
    dup from>> "From" set-header
    [ extract-email ] change-from
    dup to>> ", " join "To" set-header
    [ [ extract-email ] map ] change-to
    dup subject>> "Subject" set-header
    now timestamp>rfc822-string "Date" set-header
    message-id "Message-Id" set-header ;

: <email> ( -- email )
    email construct-empty
    H{ } clone >>headers ;

: send ( email -- )
    prepare (send) ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
