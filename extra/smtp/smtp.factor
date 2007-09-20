! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! cram-md5 auth code contributed by Dirk Vleugels <dvl@2scale.net>

USING: alien alien.c-types combinators crypto.common crypto.hmac base64
kernel io io.sockets namespaces sequences splitting ;

IN: smtp

! =========================================================
! smtp.factor implementation
! =========================================================

! Connection default values
: default-port  25                      ; inline
: read-timeout  60000                   ; inline
: esmtp         t                       ; inline ! t = ehlo
: domain        "localhost.localdomain" ; inline

SYMBOL: sess
SYMBOL: conn
SYMBOL: challenge

TUPLE: session address port timeout domain esmtp ;

: <session> ( address -- session )
    default-port read-timeout domain esmtp
    session construct-boa ;

! =========================================================
! Initialization routines
! =========================================================

: initialize ( address -- )
    <session> sess set ;

: set-port ( port -- )
    sess get set-session-port ;

: set-read-timeout ( timeout -- )
    sess get set-session-timeout ;

: set-esmtp ( esmtp -- )
    sess get set-session-esmtp ;

: set-domain ( -- )
    host-name sess get set-session-domain ;

: do-start ( -- )
    sess get [ session-address ] keep session-port <inet> <client>
    dup conn set [ sess get session-timeout swap set-timeout ]
    keep stream-readln print ;

! =========================================================
! Command routines
! =========================================================

: check-response ( response -- )
    {
        { [ dup "220" head? ] [ print ] }
        { [ dup "235" swap subseq? ] [ print ] }
        { [ dup "250" head? ] [ print ] }
        { [ dup "221" head? ] [ print ] }
        { [ dup "bye" head? ] [ print ] }
        { [ dup "4" head? ] [ "server busy" throw ] }
        { [ dup "334" head? ] [ " " split 1 swap nth base64> challenge set ] }
        { [ dup "354" head? ] [ print ] }
        { [ dup "50" head? ] [ print "syntax error" throw ] }
        { [ dup "53" head? ] [ print "invalid authentication data" throw ] }
        { [ dup "55" head? ] [ print "fatal error" throw ] }
        { [ t ] [ "unknow error" throw ] }
    } cond ;

SYMBOL: multiline

: multiline? ( response -- boolean )
    CHAR: - swap index 3 = ;

: process-multiline ( -- response )
    conn get stream-readln dup
    multiline get " " append head? [ 
        print
    ] [
        check-response process-multiline
    ] if ;

: recv-response ( -- response )
    conn get stream-readln
    dup multiline? [
        dup 3 head multiline set process-multiline
    ] [ ] if ;

: get-ok ( command -- )
    >r conn get r> over stream-write stream-flush
    recv-response check-response ;

: helo ( -- )
    "HELO " sess get session-domain append "\r\n" append get-ok ;

: ehlo ( -- )
    "EHLO " sess get session-domain append "\r\n" append get-ok ;

: mailfrom ( fromaddr -- )
    "MAIL FROM:<" swap append ">\r\n" append get-ok ;

: rcptto ( to -- )
    "RCPT TO:<" swap append ">\r\n" append get-ok ;

: (cram-md5-auth) ( -- response )
    swap challenge get 
    string>md5-hmac hex-string 
    " " swap append append 
    >base64 ;

: cram-md5-auth ( key login  -- )
    "AUTH CRAM-MD5\r\n" get-ok 
    (cram-md5-auth) "\r\n" append get-ok ;
  
: data ( -- )
    "DATA\r\n" get-ok ;

: start ( -- )
    set-domain ! replaces localhost.localdomain with hostname
    do-start
    sess get session-esmtp [
        ehlo
    ] [
        helo
    ] if ;

: send-message ( msg -- )
    data
    "\r\n" join conn get swap "\r\n" append over stream-write
    stream-flush ".\r\n" get-ok ;

: quit ( -- )
    "QUIT\r\n" get-ok ;
