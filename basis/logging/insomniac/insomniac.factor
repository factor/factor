! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.analysis logging.server logging smtp kernel
io.files io.streams.string namespaces make timers assocs
io.encodings.utf8 accessors calendar sequences locals ;
QUALIFIED: io.sockets
IN: logging.insomniac

SYMBOL: insomniac-sender
SYMBOL: insomniac-recipients

: email-subject ( service -- string )
    [
        "Log analysis for " % % " on " % io.sockets:host-name %
    ] "" make ;

:: (email-log-report) ( service word-names -- )
    <email>
        [ service word-names analyze-log-file ] with-string-writer >>body
        insomniac-recipients get >>to
        insomniac-sender get >>from
        service email-subject >>subject
    send-email ;

\ (email-log-report) NOTICE add-error-logging

: email-log-report ( service word-names -- )
    "logging.insomniac" [ (email-log-report) ] with-logging ;

: schedule-insomniac ( service word-names -- )
    [ email-log-report rotate-logs ] 2curry
    1 days every drop ;
