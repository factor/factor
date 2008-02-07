! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.analysis logging.server logging smtp io.sockets
kernel io.files io.streams.string namespaces raptor.cron ;
IN: logging.insomniac

SYMBOL: insomniac-config

SYMBOL: insomniac-smtp-host
SYMBOL: insomniac-smtp-port
SYMBOL: insomniac-sender
SYMBOL: insomniac-recipients

: ?log-analysis ( service word-names -- string/f )
    >r log-path 1 log# dup exists? [
        file-lines r> [ log-analysis ] string-out
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
        ?log-analysis dup [
            r> email-subject
            insomniac-recipients get
            insomniac-sender get
            send-simple-message
        ] [ r> 2drop ] if
    ] with-insomniac-smtp ;

: email-log-report ( service word-names -- )
    (email-log-report) ;

\ email-log-report NOTICE add-error-logging

: schedule-insomniac ( service word-names -- )
    { 25 } { 6 } f f f <when> -rot
    [ email-log-report ] 2curry schedule ;
