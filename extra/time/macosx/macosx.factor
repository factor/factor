! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data calendar calendar.unix classes.struct
io.files.info.unix.private kernel libc system time unix
unix.time ;
IN: time.macosx

M: macosx adjust-time-monotonic
    timestamp>timeval
    \ timeval new
    [ adjtime io-error ] keep dup binary-zero? [
        drop instant
    ] [
        timeval>duration since-1970 now time-
    ] if ;
