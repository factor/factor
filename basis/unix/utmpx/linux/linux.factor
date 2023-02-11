! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar.unix combinators kernel system
unix.ffi unix.utmpx ;
IN: unix.utmpx.linux

M: linux utmpx>utmpx-record
    [ new-utmpx-record ] dip {
        [ ut_user>> __UT_NAMESIZE memory>string >>user ]
        [ ut_id>>   4 memory>string >>id ]
        [ ut_line>> __UT_LINESIZE memory>string >>line ]
        [ ut_pid>>  >>pid ]
        [ ut_type>> >>type ]
        [ ut_tv>>   timeval>unix-time >>timestamp ]
        [ ut_host>> __UT_HOSTSIZE memory>string >>host ]
    } cleave ;
