! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors command-line formatting io io.monitors
kernel namespaces sequences ;

IN: file-monitor

: file-monitor-loop ( monitor -- )
    dup next-change [ changed>> ] [ path>> ] bi
    "%u %s\n" printf flush file-monitor-loop ;

: file-monitor-main ( -- )
    command-line get ?first "." or
    dup "Monitoring %s\n" printf flush
    [ t [ file-monitor-loop ] with-monitor ] with-monitors ;

MAIN: file-monitor-main
