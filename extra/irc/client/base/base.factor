! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs concurrency.mailboxes io kernel namespaces
strings words.symbol irc.client.chats irc.messages ;
EXCLUDE: sequences => join ;
IN: irc.client.base

SYMBOL: current-irc-client

: irc> ( -- irc-client ) current-irc-client get ;
: stream> ( -- stream ) irc> stream>> ;
: irc-print ( s -- ) stream> [ stream-print ] [ stream-flush ] bi ;
: irc-send ( irc-message -- ) irc> out-messages>> mailbox-put ;
: chats> ( -- seq ) irc> chats>> values ;
: me? ( string -- ? ) irc> nick>> = ;

: with-irc ( irc-client quot: ( -- ) -- )
    \ current-irc-client swap with-variable ; inline

UNION: to-target privmsg notice ;
UNION: to-channel join part topic kick rpl-channel-modes
                  topic rpl-names rpl-names-end ;
UNION: to-one-chat to-target to-channel mode ;
UNION: to-many-chats nick quit ;
UNION: to-all-chats irc-end irc-disconnected irc-connected ;
PREDICATE: to-me < to-target target>> me? ;

GENERIC: chat-name ( irc-message -- name )
M: mode       chat-name name>> ;
M: to-target  chat-name target>> ;
M: to-me      chat-name sender>> ;
M: to-channel chat-name channel>> ;

GENERIC: chat> ( obj -- chat/f )
M: string      chat> irc> chats>> at ;
M: symbol      chat> irc> chats>> at ;
M: to-one-chat chat> chat-name +server-chat+ or chat> ;
