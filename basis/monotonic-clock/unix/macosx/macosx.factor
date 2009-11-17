! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax classes.struct kernel math
monotonic-clock system unix.types ;
IN: monotonic-clock.unix.macosx

STRUCT: mach_timebase_info
    { numer uint32_t }
    { denom uint32_t } ;

TYPEDEF: mach_timebase_info* mach_timebase_info_t
TYPEDEF: mach_timebase_info mach_timebase_info_data_t

FUNCTION: uint64_t mach_absolute_time ( ) ;
FUNCTION: kern_return_t mach_timebase_info ( mach_timebase_info_t info ) ;
FUNCTION: kern_return_t mach_wait_until ( uint64_t deadline ) ;

ERROR: mach-timebase-info ret ;

M: macosx monotonic-count 
    mach_absolute_time
    \ mach_timebase_info <struct> [
        mach_timebase_info [ mach-timebase-info ] unless-zero
    ] keep [ numer>> ] [ denom>> ] bi [ * ] dip /i ;
