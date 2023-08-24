! Copyright (C) 2009 Elie Chaftari.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators concurrency.promises
destructors io io.crlf io.encodings.utf8 io.sockets
io.sockets.secure.debug io.streams.duplex io.timeouts kernel
math.parser namespaces sequences threads ;
IN: pop3.server

! Mock POP3 server for testing purposes.

! $ telnet 127.0.0.1 (start-pop3-server outputs listening port)
! Trying 127.0.0.1...
! Connected to localhost.
! Escape character is '^]'.
! +OK POP3 server ready
! USER username@host.com
! +OK Password required
! PASS password
! +OK Logged in
! STAT
! +OK 2 1753
! LIST
! +OK 2 messages:
! 1 1006
! 2 747
! .
! UIDL 1
! +OK 1 000000d547ac2fc2
! TOP 1 0
! +OK
! Return-Path: <from.first@mail.com>
! Delivered-To: username@host.com
! Received: from User.local ([66.249.71.201])
! 	by mail.isp.com  with ESMTP id n95BgmJg012655
! 	for <username@host.com>; Mon, 5 Oct 2009 14:42:59 +0300
! Date: Mon, 5 Oct 2009 14:42:31 +0300
! Message-Id: <4273644000823950677-1254742951070701@User.local>
! MIME-Version: 1.0
! Content-Transfer-Encoding: base64
! From: from.first@mail.com
! To: username@host.com
! Subject: First test with mock POP3 server
! Content-Type: text/plain; charset=UTF-8
!
! .
! DELE 1
! +OK Marked for deletion
! QUIT
! +OK POP3 server closing connection
! Connection closed by foreign host.

: process ( -- )
    read-crlf {
        {
            [ dup "USER" head? ]
            [

                "+OK Password required\r\n"
                write flush t
            ]
        }
        {
            [ dup "PASS" head? ]
            [
                "+OK Logged in\r\n"
                write flush t
            ]
        }
        {
            [ dup "CAPA" = ]
            [
                "+OK\r\nCAPA\r\nTOP\r\nUIDL\r\n.\r\n"
                write flush t
            ]
        }
        {
            [ dup "STAT" = ]
            [
                "+OK 2 1753\r\n"
                write flush t
            ]
        }
        {
            [ dup "LIST" = ]
            [
                "+OK 2 messages:\r\n1 1006\r\n2 747\r\n.\r\n"
                write flush t
            ]
        }
        {
            [ dup "UIDL" head? ]
            [
                {
                    {
                        [ dup "UIDL 1" = ]
                        [
                            "+OK 1 000000d547ac2fc2\r\n"
                            write flush t
                        ]
                    }
                    {
                        [ dup "UIDL 2" = ]
                        [
                            "+OK 2 000000d647ac2fc2\r\n"
                            write flush t
                        ]
                    }
                        [
                            "+OK\r\n1 000000d547ac2fc2\r\n2 000000d647ac2fc2\r\n.\r\n"
                            write flush t
                        ]
                } cond
            ]
        }
        {
            [ dup "TOP" head? ]
            [
                {
                    {
                        [ dup "TOP 1 0" = ]
                        [
"+OK
Return-Path: <from.first@mail.com>
Delivered-To: username@host.com
Received: from User.local ([66.249.71.201])
	by mail.isp.com  with ESMTP id n95BgmJg012655
	for <username@host.com>; Mon, 5 Oct 2009 14:42:59 +0300
Date: Mon, 5 Oct 2009 14:42:31 +0300
Message-Id: <4273644000823950677-1254742951070701@User.local>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
From: from.first@mail.com
To: username@host.com
Subject: First test with mock POP3 server
Content-Type: text/plain; charset=UTF-8

.
"
                            write flush t
                        ]
                    }
                    {
                        [ dup "TOP 2 0" = ]
                        [
"+OK
Return-Path: <from.second@mail.com>
Delivered-To: username@host.com
Received: from User.local ([66.249.71.201])
	by mail.isp.com  with ESMTP id n95BgmJg012655
	for <username@host.com>; Mon, 5 Oct 2009 14:44:09 +0300
Date: Mon, 5 Oct 2009 14:43:11 +0300
Message-Id: <9783644000823934577-4563442951070856@User.local>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
From: from.second@mail.com
To: username@host.com
Subject: Second test with mock POP3 server
Content-Type: text/plain; charset=UTF-8

.
"
                            write flush t
                        ]
                    }
                } cond
            ]
        }
        {
            [ dup "RETR" head? ]
            [
                {
                    {
                        [ dup "RETR 1" = ]
                        [
"+OK
Return-Path: <from.first@mail.com>
Delivered-To: username@host.com
Received: from User.local ([66.249.71.201])
	by mail.isp.com  with ESMTP id n95BgmJg012655
	for <username@host.com>; Mon, 5 Oct 2009 14:42:59 +0300
Date: Mon, 5 Oct 2009 14:42:31 +0300
Message-Id: <4273644000823950677-1254742951070701@User.local>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
From: from.first@mail.com
To: username@host.com
Subject: First test with mock POP3 server
Content-Type: text/plain; charset=UTF-8

This is the body of the first test. 
.
"
                            write flush t
                        ]
                    }
                    {
                        [ dup "RETR 2" = ]
                        [
"+OK
Return-Path: <from.second@mail.com>
Delivered-To: username@host.com
Received: from User.local ([66.249.71.201])
	by mail.isp.com  with ESMTP id n95BgmJg012655
	for <username@host.com>; Mon, 5 Oct 2009 14:44:09 +0300
Date: Mon, 5 Oct 2009 14:43:11 +0300
Message-Id: <9783644000823934577-4563442951070856@User.local>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
From: from.second@mail.com
To: username@host.com
Subject: Second test with mock POP3 server
Content-Type: text/plain; charset=UTF-8

This is the body of the second test. 
.
"
                            write flush t
                        ]
                    }
                } cond
            ]
        }
        {
            [ dup "DELE" head? ]
            [
                "+OK Marked for deletion\r\n"
                write flush t
            ]
        }
        {
            [ dup "RSET" = ]
            [
                "+OK\r\n"
                write flush t
            ]
        }
        {
            [ dup "QUIT" = ]
            [
                "+OK POP3 server closing connection\r\n"
                write flush f
            ]
        }
    } cond nip [ process ] when ;

:: mock-pop3-server ( promise -- )
    ! Store the port we are running on in the promise.
    [
        [
            "127.0.0.1" 0 <inet4> utf8 <server> [
            dup addr>> port>> promise fulfill
                accept drop [
                    1 minutes timeouts
                    "+OK POP3 server ready\r\n" write flush
                    process
                    [ flush ] with-global
                ] with-stream
            ] with-disposal
        ] with-test-context
    ] in-thread ;

: start-pop3-server ( -- )
    <promise> [ mock-pop3-server ] keep ?promise
    number>string "POP3 server started on port "
    prepend print ;
