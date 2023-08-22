! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs concurrency.mailboxes io irc.client.chats
irc.messages kernel namespaces sequences strings words.symbol ;
IN: irc.client.base

SYMBOL: current-irc-client

: irc> ( -- irc-client ) current-irc-client get ;
: stream> ( -- stream ) irc> stream>> ;
: irc-print ( s -- ) stream> [ stream-print ] [ stream-flush ] bi ;
: irc-send ( irc-message -- ) irc> out-messages>> mailbox-put ;
: chats> ( -- seq ) irc> chats>> values ;
: me? ( string -- ? ) irc> nick>> = ;

: with-irc ( ..a irc-client quot: ( ..a -- ..b ) -- ..b )
    \ current-irc-client swap with-variable ; inline

UNION: to-target privmsg notice ;
UNION: to-channel irc.messages:join part topic kick rpl-channel-modes
                  topic rpl-names rpl-names-end ;
UNION: to-one-chat to-target to-channel mode ;
UNION: to-many-chats nick quit ;
UNION: to-all-chats irc-end irc-disconnected irc-connected ;
PREDICATE: to-me < to-target target>> me? ;

GENERIC: chat-name ( irc-message -- name )
M: mode       chat-name name>> ;
M: to-target  chat-name target>> ;
M: to-me      chat-name sender>> ;

! to-channel messages are things like JOIN
! Freenode's join looks like:
! ":flogbot2_!~flogbot2@c-50-174-221-28.hsd1.ca.comcast.net JOIN #concatenative-bots"
! The channel>> field is empty and it's in parameters instead.
! This fixes chat> for these kinds of messages.
M: to-channel chat-name [ channel>> ] [ parameters>> ?first ] ?unless ;

GENERIC: chat> ( obj -- chat/f )
M: string      chat> irc> chats>> at ;
M: symbol      chat> irc> chats>> at ;
M: to-one-chat chat> chat-name +server-chat+ or chat> ;
