! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel prettyprint io io.timeouts io.server
sequences namespaces io.sockets continuations calendar
io.encodings.ascii io.streams.duplex destructors ;
IN: smtp.server

! Mock SMTP server for testing purposes.

! Usage: 4321 mock-smtp-server
! $ telnet 127.0.0.1 4321
! Trying 127.0.0.1...
! Connected to localhost.
! Escape character is '^]'.
! 220 hello
! EHLO
! 220 and..?
! MAIL FROM: <here@mail.com>
! 220 OK
! RCPT TO: <there@mail.com>
! 220 OK
! Hi
! 500 ERROR
! DATA
! 354 Enter message, ending with "." on a line by itself
! Hello I am still waiting for your call
! Thanks
! .
! 220 OK
! QUIT
! bye
! Connection closed by foreign host.

SYMBOL: data-mode

: process ( -- )
    readln {
        { [ [ dup "HELO" head? ] keep "EHLO" head? or ] [ 
            "220 and..?\r\n" write flush t
          ] }
        { [ dup "QUIT" = ] [ 
            "bye\r\n" write flush f
          ] }
        { [ dup "MAIL FROM:" head? ] [ 
            "220 OK\r\n" write flush t
          ] }
        { [ dup "RCPT TO:" head? ] [ 
            "220 OK\r\n" write flush t
          ] }
        { [ dup "DATA" = ] [
            data-mode on 
            "354 Enter message, ending with \".\" on a line by itself\r\n"
            write flush t
          ] }
        { [ dup "." = data-mode get and ] [
            data-mode off
            "220 OK\r\n" write flush t
          ] }
        { [ data-mode get ] [ dup global [ print ] bind t ] }
        [ 
            "500 ERROR\r\n" write flush t
        ]
    } cond nip [ process ] when ;

: mock-smtp-server ( port -- )
    "Starting SMTP server on port " write dup . flush
    "127.0.0.1" swap <inet4> ascii <server> [
        accept drop [
            1 minutes timeouts
            "220 hello\r\n" write flush
            process
            global [ flush ] bind
        ] with-stream
    ] with-disposal ;
