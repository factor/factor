! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar.unix combinators kernel system
unix.ffi unix.utmpx ;
IN: unix.utmpx.macos

M: macos utmpx>utmpx-record
    [ new-utmpx-record ] dip {
        [ ut_user>> _UTX_USERSIZE memory>string >>user ]
        [ ut_id>>   _UTX_IDSIZE memory>string >>id ]
        [ ut_line>> _UTX_LINESIZE memory>string >>line ]
        [ ut_pid>>  >>pid ]
        [ ut_type>> >>type ]
        [ ut_tv>>   timeval>unix-time >>timestamp ]
        [ ut_host>> _UTX_HOSTSIZE memory>string >>host ]
    } cleave ;
