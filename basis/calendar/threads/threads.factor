! Copyright (C) 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar math system threads ;
IN: calendar.threads

M: duration sleep
    duration>nanoseconds >integer nano-count + sleep-until ;
