! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar classes.struct kernel libc math
system time unix unix.time ;
IN: time.unix

: timestamp>timezone ( timestamp -- timezone )
    gmt-offset>> duration>minutes 1 \ timezone boa ; inline

M: unix set-system-time
    [ unix-1970 time- duration>microseconds >integer make-timeval ]
    [ timestamp>timezone ] bi
    settimeofday io-error ;
