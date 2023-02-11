! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar concurrency.mailboxes
io.encodings.utf8 io.sockets kernel ;
IN: irc.client.chats

CONSTANT: irc-port 6667 ! Default irc port

TUPLE: irc-chat in-messages client ;
TUPLE: irc-server-chat  < irc-chat ;
TUPLE: irc-channel-chat < irc-chat name password participants clear-participants ;
TUPLE: irc-nick-chat    < irc-chat name ;
SYMBOL: +server-chat+

: <irc-server-chat> ( -- irc-server-chat )
    irc-server-chat new
         <mailbox> >>in-messages ;

: <irc-channel-chat> ( name -- irc-channel-chat )
    irc-channel-chat new
         swap       >>name
         <mailbox>  >>in-messages
         f          >>password
         H{ } clone >>participants
         t          >>clear-participants ;

: <irc-nick-chat> ( name -- irc-nick-chat )
    irc-nick-chat new
         swap      >>name
         <mailbox> >>in-messages ;

TUPLE: irc-profile server port nickname password ;
C: <irc-profile> irc-profile

TUPLE: irc-client profile stream in-messages out-messages
    chats is-running nick connect is-ready
    reconnect-time reconnect-attempts
    exceptions ;

: <irc-client> ( profile -- irc-client )
    dup nickname>> irc-client new
        swap       >>nick
        swap       >>profile
        <mailbox>  >>in-messages
        <mailbox>  >>out-messages
        H{ } clone >>chats
        30 seconds >>reconnect-time
        10         >>reconnect-attempts
        V{ } clone >>exceptions
        [ <inet> utf8 <client> drop ] >>connect ;

SINGLETONS: irc-chat-end irc-end irc-disconnected irc-connected ;
