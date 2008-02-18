! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads ;
IN: concurrency.exchangers

! Motivated by
! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

TUPLE: exchanger thread ;

: <exchanger> ( -- exchanger )
    f exchanger construct-boa ;

: exchange ( obj exchanger -- newobj )
    dup exchanger-thread [
        dup exchanger-thread
        f rot set-exchanger-thread
        resume-with
    ] [
        [ set-exchanger-thread ] curry suspend
    ] if ;
