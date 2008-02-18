! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads ;
IN: concurrency.exchangers

! Motivated by
! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

TUPLE: exchanger thread object ;

: <exchanger> ( -- exchanger )
    f f exchanger construct-boa ;

: pop-object ( exchanger -- obj )
    dup exchanger-object f rot set-exchanger-object ;

: pop-thread ( exchanger -- thread )
    dup exchanger-thread f rot set-exchanger-thread ;

: exchange ( obj exchanger -- newobj )
    dup exchanger-thread [
        dup pop-object >r pop-thread resume-with r>
    ] [
        [ set-exchanger-object ] keep
        [ set-exchanger-thread ] curry suspend
    ] if ;
