! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry irc.client irc.client.chats kernel namespaces
sequences threads io.encodings.8-bit io.launcher io splitting
make mason.common mason.updates calendar math alarms ;
IN: irc.gitbot

: bot-profile ( -- obj )
    "irc.freenode.org" 6667 "jackass" f <irc-profile> ;

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
        "git-log" ,
        "--no-merges" ,
        "--pretty=format:%h %an: %s" ,
        ".." glue ,
    ] { } make
    latin1 [ lines ] with-process-reader ;

: updates ( from to -- lines )
    git-log reverse
    dup length 4 > [ 4 head "... and more" suffix ] when ;

: report-updates ( from to chat -- )
    [ updates ] dip
    [ 1 seconds sleep ] swap
    '[ _ speak ] interleave ;

: check-for-updates ( chat -- )
    [ git-id git-pull-cmd short-running-process git-id ] dip
    report-updates ;

: bot ( -- )
    start-bot
    '[ _ check-for-updates ] 5 minutes every drop ;

MAIN: bot
