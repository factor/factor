! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax ;
IN: irc.client.chats

HELP: irc-client "IRC Client object" ;

HELP: irc-server-chat "Chat for server messages unmanaged by other chats" ;

HELP: irc-channel-chat "Chat for irc channels" ;

HELP: irc-nick-chat "Chat for irc users" ;

HELP: irc-profile "IRC Client profile object" ;

HELP: irc-chat-end "Message sent to a chat when it has been detached from the client, the chat should stop after it receives this message." ;

HELP: irc-end "Message sent when the client isn't running anymore, the chat should stop after it receives this message." ;

HELP: irc-disconnected "Message sent to notify chats that connection was lost." ;

HELP: irc-connected "Message sent to notify chats that a connection with the irc server was established." ;
