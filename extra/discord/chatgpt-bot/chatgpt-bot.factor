! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs discord hashtables kernel openai sequences
splitting unicode ;
IN: discord.chatgpt-bot

GENERIC: discord-chatgpt-bot ( json opcode -- )

M: object discord-chatgpt-bot 2drop ;

: first-chat-completion ( json -- string/f )
    "choices" of [
        "chatgpt gave empty response" reply-message f
    ] [
        first "message" of "content" of
    ] if-empty ;

M: MESSAGE_CREATE discord-chatgpt-bot drop
    dup obey-message? [
        "content" of "chatgpt: " ?head [
            [ blank? ] trim
            '{ { "role" "user" } { "content" _ } } >hashtable 1array
            <cheapest-chat-completion>
            [ g... gflush ] [ chat-completions ] bi
            first-chat-completion reply-message
        ] [
            drop
        ] if
    ] [
        drop
    ] if ;
