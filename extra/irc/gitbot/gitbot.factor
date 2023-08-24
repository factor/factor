! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar debugger io io.encodings.utf8 io.launcher
irc.client irc.client.chats kernel make mason.common mason.git
math namespaces sequences threads timers ;
IN: irc.gitbot

SYMBOL: nickserv-handle
SYMBOL: nickserv-password

: bot-profile ( -- obj )
    "irc.libera.chat" 6697
    nickserv-handle get "stackoid2" or
    nickserv-password get <irc-profile> ;

: bot-channel ( -- seq ) "#concatenative" ;

GENERIC: handle-message ( msg -- )

M: object handle-message drop ;

: bot-loop ( chat -- )
    dup hear handle-message bot-loop ;

: start-bot ( -- chat )
    bot-profile <irc-client>
    [ connect-irc ]
    [
        [ bot-channel <irc-channel-chat> dup ] dip
        '[ _ [ _ attach-chat ] [ bot-loop ] bi ]
        "GitBot" spawn drop
    ] bi ;

: git-log ( from to -- lines )
    [
        "git" ,
        "log" ,
        "--no-merges" ,
        "--pretty=format:%h %an: %s" ,
        ".." glue ,
    ] { } make
    process-lines ;

: updates ( from to -- lines )
    git-log reverse
    dup length 4 > [ 4 head "... and more" suffix ] when ;

: report-updates ( from to chat -- )
    [ updates ] dip
    [ 1 seconds sleep ] swap
    '[ _ speak ] interleave ;

: check-for-updates ( chat -- )
    '[
        git-id
        { "git" "pull" "origin" "master" } short-running-process
        git-id
        _ report-updates
    ] try ;

: bot ( -- )
    start-bot
    '[ _ check-for-updates ] 5 minutes every drop ;

MAIN: bot
