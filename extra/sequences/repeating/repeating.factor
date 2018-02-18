! Copyright (C) 2008 Alex Chapman
! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors circular kernel math sequences sequences.private ;
IN: sequences.repeating

TUPLE: cycles
{ circular circular read-only }
{ length integer read-only } ;

: <cycles> ( seq length -- cycles )
    [ <circular> ] dip cycles boa ;

: cycle ( seq length -- new-seq )
    dupd <cycles> swap like ;

M: cycles length length>> ;

M: cycles set-length length<< ;

M: cycles virtual@ circular>> ;

M: cycles virtual-exemplar circular>> ;

INSTANCE: cycles virtual-sequence

TUPLE: repeats
{ seq sequence read-only }
{ times integer read-only } ;

C: <repeats> repeats

M: repeats length [ seq>> length ] [ times>> ] bi * ;

M: repeats virtual@ [ times>> /i ] [ seq>> ] bi ;

M: repeats virtual-exemplar seq>> ;

INSTANCE: repeats immutable-sequence

INSTANCE: repeats virtual-sequence

: repeat ( seq times -- new-seq )
    dupd <repeats> swap like ;
