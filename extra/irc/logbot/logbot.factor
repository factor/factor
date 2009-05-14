! Copyright (C) 2009 Bruno Deferrari.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format destructors fry io io.encodings.8-bit
io.files io.pathnames irc.client irc.client.chats irc.messages
irc.messages.base kernel make namespaces sequences threads
irc.logbot.log-line ;
IN: irc.logbot

CONSTANT: bot-channel "#concatenative"
CONSTANT: log-directory "/tmp/logs"

SYMBOL: current-day
SYMBOL: current-stream

: bot-profile ( -- obj )
    "irc.freenode.org" 6667 "flogger" f <irc-profile> ;

: add-timestamp ( string timestamp -- string )
    timestamp>hms [ "[" % % "] " % % ] "" make ;

: timestamp-path ( timestamp -- path )
    timestamp>ymd ".log" append log-directory prepend-path ;

: timestamp>stream ( timestamp  -- stream )
    dup day-of-year current-day get = [
        drop
    ] [
        current-stream get [ dispose ] when*
        [ day-of-year current-day set ]
        [ timestamp-path latin1 <file-appender> ] bi
        current-stream set
    ] if current-stream get ;

: log-message ( string timestamp -- )
    [ add-timestamp ] [ timestamp>stream ] bi
    [ stream-print ] [ stream-flush ] bi ;

GENERIC: handle-message ( msg -- )

M: object      handle-message drop ;
M: irc-message handle-message [ >log-line ] [ timestamp>> ] bi log-message ;

: bot-loop ( chat -- ) dup hear handle-message bot-loop ;

: start-bot ( -- )
    bot-profile <irc-client>
    [ connect-irc ]
    [
        [ bot-channel <irc-channel-chat> ] dip
        '[ _ [ _ attach-chat ] [ bot-loop ] bi ]
        "LogBot" spawn drop
    ] bi ;

: logbot ( -- ) start-bot ;

MAIN: logbot
