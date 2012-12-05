! Copyright (C) 2008 Alex Chapman
! Copyright (C) 2012 John Benediktsson
! See http;//factorcode.org/license.txt for BSD license
USING: accessors circular kernel math sequences sequences.private ;
IN: sequences.repeating

TUPLE: cycles circular length ;

: <cycles> ( seq length -- cycles )
    [ <circular> ] dip cycles boa ;

: cycle ( seq length -- new-seq )
    dupd <cycles> swap like ;

M: cycles length length>> ;
M: cycles set-length length<< ;

M: cycles virtual@ ( n seq -- n' seq' ) circular>> ;

M: cycles virtual-exemplar circular>> ;

INSTANCE: cycles virtual-sequence

TUPLE: repeats seq length ;

: <repeats> ( seq times -- repeats )
    over length * repeats boa ;

: repeat ( seq times -- new-seq )
    dupd <repeats> swap like ;

M: repeats length length>> ;

M: repeats nth-unsafe seq>> [ length /i ] keep nth ;

INSTANCE: repeats immutable-sequence
