! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar calendar.format
combinators.smart io io.crlf io.encodings.utf8 kernel
managed-server namespaces sequences sorting splitting unicode ;
IN: managed-server.chat

TUPLE: chat-server < managed-server ;

SYMBOL: commands
commands [ H{ } clone ] initialize

SYMBOL: chat-docs
chat-docs [ H{ } clone ] initialize

CONSTANT: line-beginning "-!- "

: send-line ( string -- )
    write crlf flush ;

: handle-me ( string -- )
    [
        [ "* " username " " ] dip
    ] "" append-outputs-as send-everyone ;

: handle-quit ( string -- )
    client [ object<< ] [ t >>quit? drop ] bi ;

: handle-help ( string -- )
    [
        "Commands: "
        commands get keys sort ", " join append send-line
    ] [
        chat-docs get ?at
        [ send-line ]
        [ "Unknown command: " prepend send-line ] if
    ] if-empty ;

: usage ( string -- )
    chat-docs get at send-line ;

: username-taken-string ( username -- string )
    "The username '" "' is already in use; try again." surround ;

: warn-name-changed ( old new -- )
    [
        [ line-beginning "'" ] 2dip
        [ "' is now known as '" ] dip "'"
    ] "" append-outputs-as send-everyone ;

: handle-nick ( string -- )
    [
        "nick" usage
    ] [
        dup clients key? [
            username-taken-string send-line
        ] [
            [ username swap warn-name-changed ]
            [ username clients rename-at ]
            [ client username<< ] tri
        ] if
    ] if-empty ;

:: add-command ( quot docs key -- )
    quot key commands get set-at
    docs key chat-docs get set-at ;

[ handle-help ]
"Syntax: /help [command]
Displays the documentation for a command."
"help" add-command

[ drop clients keys [ "'" dup surround ] map ", " join send-line ]
"Syntax: /who
Shows the list of connected users."
"who" add-command

[ drop now-gmt timestamp>rfc822 send-line ]
"Syntax: /time
Returns the current GMT time." "time" add-command

[ handle-nick ]
"Syntax: /nick nickname
Changes your nickname."
"nick" add-command

[ handle-me ]
"Syntax: /me action"
"me" add-command

[ handle-quit ]
"Syntax: /quit [message]
Disconnects a user from the chat server." "quit" add-command

: handle-command ( string -- )
    dup " " split1 swap >lower commands get at* [
        call( string -- ) drop
    ] [
        2drop "Unknown command: " prepend send-line
    ] if ;

: <chat-server> ( port -- managed-server )
    "chat-server" utf8 chat-server new-managed-server ;

: handle-chat ( string -- )
    [
        [ username ": " ] dip
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-login
    "Username: " write flush
    readln ;

M: chat-server handle-client-join
    [
        line-beginning username " has joined"
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-client-disconnect
    [
        line-beginning username " has quit  "
        client object>> dup [ "\"" 1surround ] when
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-already-logged-in
    username username-taken-string send-line
    t client quit?<< ;

M: chat-server handle-managed-client*
    readln dup f = [ t client quit?<< ] when
    [
        "/" ?head [ handle-command ] [ handle-chat ] if
    ] unless-empty ;
