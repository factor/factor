! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors command-line formatting fry io io.monitors
io.pathnames kernel namespaces sequences ;

IN: file-monitor

: file-monitor-loop ( monitor -- )
    '[
        _ next-change
        [ changed>> ] [ path>> ] bi
        "%u %s\n" printf flush t
    ] loop ;

: file-monitor-main ( -- )
    command-line get ?first current-directory get or
    dup "Monitoring %s\n" printf flush
    [ t <monitor> file-monitor-loop ] with-monitors ;

MAIN: file-monitor-main
