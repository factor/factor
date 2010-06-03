! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces accessors combinators make smtp debugger
prettyprint sequences io io.streams.string io.encodings.utf8 io.files
io.sockets mason.common mason.platform mason.config ;
IN: mason.email

: mason-email ( body content-type subject -- )
    <email>
        builder-from get >>from
        builder-recipients get >>to
        swap >>subject
        swap >>content-type
        swap >>body
    send-email ;

: subject-prefix ( -- string )
    "mason on " platform ": " 3append ;

: report-subject ( status -- string )
    [
        subject-prefix %
        current-git-id get 7 short head %
        " -- " %
        {
            { status-clean [ "clean" ] }
            { status-dirty [ "dirty" ] }
            { status-error [ "error" ] }
        } case %
    ] "" make ;

: email-report ( report status -- )
    [ "text/html" ] dip report-subject mason-email ;

: email-error ( error callstack -- )
    [
        "Fatal error on " write host-name print nl
        [ error. ] [ callstack. ] bi*
    ] with-string-writer
    "text/plain"
    subject-prefix "fatal error" append
    mason-email ;
