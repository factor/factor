! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.analysis logging.server logging smtp io.sockets
kernel io.files io.streams.string namespaces raptor.cron assocs ;
IN: logging.insomniac

SYMBOL: insomniac-smtp-host
SYMBOL: insomniac-smtp-port
SYMBOL: insomniac-sender
SYMBOL: insomniac-recipients

: ?analyze-log ( service word-names -- string/f )
    >r log-path 1 log# dup exists? [
        file-lines r> [ analyze-log ] with-string-writer
    ] [
        r> 2drop f
    ] if ;

: with-insomniac-smtp ( quot -- )
    [
        insomniac-smtp-host get [ smtp-host set ] when*
        insomniac-smtp-port get [ smtp-port set ] when*
        call
    ] with-scope ; inline

: email-subject ( service -- string )
    [ "[INSOMNIAC] " % % " on " % host-name % ] "" make ;

: (email-log-report) ( service word-names -- )
    [
        over >r
        ?analyze-log dup [
            r> email-subject
            insomniac-recipients get
            insomniac-sender get
            send-simple-message
        ] [ r> 2drop ] if
    ] with-insomniac-smtp ;

\ (email-log-report) NOTICE add-error-logging

: email-log-report ( service word-names -- )
    "logging.insomniac" [ (email-log-report) ] with-logging ;

: schedule-insomniac ( service word-names -- )
    { 25 } { 6 } f f f <when> -rot [
        [ email-log-report ] assoc-each rotate-logs
    ] 2curry schedule ;
