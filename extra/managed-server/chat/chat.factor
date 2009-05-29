! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.smart
destructors fry io kernel managed-server namespaces
sequences splitting unicode.case ;
IN: managed-server.chat

CONSTANT: line-beginning "-!- "

TUPLE: chat-server < managed-server ;

: <chat-server> ( port -- managed-server )
    "chat-server" chat-server new-managed-server ;

: unknown-command ( string -- )
    "Unknown command: " prepend print-client ;

: handle-who ( string -- )
    drop
    clients keys ", " join print flush ;

: handle-me ( string -- )
    [
        [ "* " username " " ] dip
    ] "" append-outputs-as send-everyone ;

: handle-quit ( string -- )
    client [ (>>object) ] [ output-stream>> dispose ] bi ;

: handle-command ( string -- )
    " " split1 swap >lower {
        { "who" [ handle-who ] }
        { "me" [ handle-me ] }
        { "quit" [ handle-quit ] }
        [ " " glue unknown-command ]
    } case ;

: handle-chat ( string -- )
    [
        [ username ": " ] dip
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-client-join
    [
        line-beginning username " has joined"
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-client-disconnect
    [
        line-beginning username " has quit  "
        client object>> dup [ "\"" dup surround ] when
    ] "" append-outputs-as send-everyone ;

M: chat-server handle-already-logged-in
    "The username ``" username "'' is already in use; try again."
    3append print flush ;

M: chat-server handle-managed-client*
    readln [
        "/" ?head [ handle-command ] [ handle-chat ] if
    ] unless-empty ;
