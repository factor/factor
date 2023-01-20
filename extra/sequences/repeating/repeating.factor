! Copyright (C) 2008 Alex Chapman
! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors circular kernel math sequences ;
IN: sequences.repeating

TUPLE: cycles
{ circular circular read-only }
{ length integer read-only } ;

: <cycles> ( seq length -- cycles )
    [ <circular> ] dip cycles boa ;

: cycle ( seq length -- new-seq )
    dupd <cycles> swap like ;

: repeat ( seq times -- new-seq )
    over length * cycle ;

M: cycles length length>> ;

M: cycles set-length length<< ;

M: cycles virtual@ circular>> ;

M: cycles virtual-exemplar circular>> ;

INSTANCE: cycles virtual-sequence

TUPLE: element-repeats
{ seq sequence read-only }
{ times integer read-only } ;

C: <element-repeats> element-repeats

M: element-repeats length [ seq>> length ] [ times>> ] bi * ;

M: element-repeats virtual@ [ times>> /i ] [ seq>> ] bi ;

M: element-repeats virtual-exemplar seq>> ;

INSTANCE: element-repeats immutable-sequence

INSTANCE: element-repeats virtual-sequence

: repeat-elements ( seq times -- new-seq )
    dupd <element-repeats> swap like ;
