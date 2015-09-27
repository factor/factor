! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads boxes accessors fry ;
IN: concurrency.exchangers

! Motivated by
! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

TUPLE: exchanger thread object ;

: <exchanger> ( -- exchanger )
    <box> <box> exchanger boa ;

: exchange ( obj exchanger -- newobj )
    dup thread>> occupied>> [
        dup object>> box>
        [ thread>> box> resume-with ] dip
    ] [
        [ object>> >box ] keep
        [ self ] dip thread>> >box
        "exchange" suspend
    ] if ;
