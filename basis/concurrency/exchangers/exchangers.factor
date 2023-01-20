! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors boxes kernel threads ;
IN: concurrency.exchangers

! Motivated by
! https://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/Exchanger.html

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
