! Copyright (C) 2009 Bruno Deferrari.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar destructors formatting io io.directories
io.encodings.utf8 io.files io.pathnames irc.client irc.client.chats
irc.logbot.log-line irc.messages.base kernel namespaces sequences
splitting threads ;
IN: irc.logbot

CONSTANT: bot-channel "#concatenative"
CONSTANT: default-log-directory "resource:logs/irc"
CONSTANT: default-nickserv-handle "flogbot2"

SYMBOL: ircbot-log-directory
SYMBOL: nickserv-handle
SYMBOL: nickserv-password

SYMBOL: current-day
SYMBOL: current-stream

: bot-profile ( -- obj )
    "irc.libera.chat" 6697
    nickserv-handle get default-nickserv-handle or
    nickserv-password get <irc-profile> ;

: add-timestamp ( string timestamp -- string )
    "[%H:%M:%S] " strftime prepend ;

: make-log-path ( -- path )
    ircbot-log-directory get default-log-directory or
    bot-channel "#" ?head drop
    append-path ;

: timestamp-path ( timestamp -- path )
    "%Y-%m-%d.log" strftime
    make-log-path dup make-directories
    prepend-path ;

: update-current-stream ( timestamp -- )
    current-stream get [ dispose ] when*
    [ day-of-year current-day set ]
    [ timestamp-path utf8 <file-appender> ] bi
    current-stream set ;

: same-day? ( timestamp -- ? ) day-of-year current-day get = ;

: timestamp>stream ( timestamp  -- stream )
    dup same-day? [ drop ] [ update-current-stream ] if
    current-stream get ;

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
