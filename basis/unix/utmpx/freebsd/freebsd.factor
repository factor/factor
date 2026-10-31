USING: accessors calendar.unix combinators kernel system
unix.ffi unix.utmpx ;
IN: unix.utmpx.freebsd

M: freebsd utmpx>utmpx-record
    [ new-utmpx-record ] dip {
        [ ut_user>> 32 memory>string >>user ]
        [ ut_id>>   8 memory>string >>id ]
        [ ut_line>> 16 memory>string >>line ]
        [ ut_pid>>  >>pid ]
        [ ut_type>> >>type ]
        [ ut_tv>>   timeval>unix-time >>timestamp ]
        [ ut_host>> 128 memory>string >>host ]
    } cleave ;
