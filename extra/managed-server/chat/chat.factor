! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry io kernel managed-server
namespaces sequences ;
IN: managed-server.chat

TUPLE: chat-server < managed-server ;

: <chat-server> ( port -- managed-server )
    "chat-server" chat-server new-managed-server ;

M: chat-server handle-managed-client*
    clients>>
    readln dup empty? [
        2drop
    ] [
        '[
            nip output-stream>>
            [
                client get username>> ": " _ 3append print flush
            ] with-output-stream*
        ] assoc-each
    ] if ;
