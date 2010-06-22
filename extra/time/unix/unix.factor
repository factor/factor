! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar kernel math system time unix unix.time ;
IN: time.unix

M: unix set-time
    [ unix-1970 time- duration>microseconds >integer make-timeval ]
    [ timestamp>timezone ] bi
    settimeofday io-error ;
