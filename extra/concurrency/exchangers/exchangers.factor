! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads boxes ;
IN: concurrency.exchangers

! Motivated by
! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

TUPLE: exchanger thread object ;

: <exchanger> ( -- exchanger )
    <box> <box> exchanger construct-boa ;

: exchange ( obj exchanger -- newobj )
    dup exchanger-thread box-full? [
        dup exchanger-object box>
        >r exchanger-thread box> resume-with r>
    ] [
        [ exchanger-object >box ] keep
        [ exchanger-thread >box ] curry "exchange" suspend
    ] if ;
