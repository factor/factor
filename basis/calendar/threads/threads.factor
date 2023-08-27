! Copyright (C) 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar threads ;
IN: calendar.threads

M: duration sleep duration>nanoseconds sleep ;

M: timestamp sleep-until now time- sleep ;
