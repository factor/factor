! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces accessors combinators make smtp debugger
prettyprint io io.streams.string io.encodings.utf8 io.files io.sockets
mason.common mason.platform mason.config ;
IN: mason.email

: prefix-subject ( str -- str' )
    [ "mason on " % platform % ": " % % ] "" make ;

: email-status ( body content-type subject -- )
    <email>
        builder-from get >>from
        builder-recipients get >>to
        swap prefix-subject >>subject
        swap >>content-type
        swap >>body
    send-email ;

: subject ( status -- str )
    {
        { status-clean [ "clean" ] }
        { status-dirty [ "dirty" ] }
        { status-error [ "error" ] }
    } case ;

: email-report ( report status -- )
    [ "text/html" ] dip subject email-status ;

: email-error ( error callstack -- )
    [
        "Fatal error on " write host-name print nl
        [ error. ] [ callstack. ] bi*
    ] with-string-writer "text/plain" "fatal error"
    email-status ;
