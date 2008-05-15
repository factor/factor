! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads boxes accessors ;
IN: concurrency.exchangers

! Motivated by
! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

TUPLE: exchanger thread object ;

: <exchanger> ( -- exchanger )
    <box> <box> exchanger boa ;

: exchange ( obj exchanger -- newobj )
    dup thread>> occupied>> [
        dup object>> box>
        >r thread>> box> resume-with r>
    ] [
        [ object>> >box ] keep
        [ thread>> >box ] curry "exchange" suspend
    ] if ;
