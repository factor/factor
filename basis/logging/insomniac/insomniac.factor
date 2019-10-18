! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.analysis logging.server logging smtp kernel
io.files io.streams.string namespaces make alarms assocs
io.encodings.utf8 accessors calendar sequences ;
QUALIFIED: io.sockets
IN: logging.insomniac

SYMBOL: insomniac-sender
SYMBOL: insomniac-recipients

: ?analyze-log ( service word-names -- string/f )
    [ analyze-log-file ] with-string-writer ;

: email-subject ( service -- string )
    [
        "[INSOMNIAC] " % % " on " % io.sockets:host-name %
    ] "" make ;

: (email-log-report) ( service word-names -- )
    dupd ?analyze-log [ drop ] [
        <email>
            swap >>body
            insomniac-recipients get >>to
            insomniac-sender get >>from
            swap email-subject >>subject
        send-email
    ] if-empty ;

\ (email-log-report) NOTICE add-error-logging

: email-log-report ( service word-names -- )
    "logging.insomniac" [ (email-log-report) ] with-logging ;

: schedule-insomniac ( service word-names -- )
    [ [ email-log-report ] assoc-each rotate-logs ] 2curry
    1 days every drop ;
