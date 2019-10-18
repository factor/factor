! Copyright (C) 2008 Alex Chapman
! See http;//factorcode.org/license.txt for BSD license
USING: accessors circular kernel sequences ;
IN: sequences.repeating

TUPLE: repeating circular len ;

: <repeating> ( seq length -- repeating )
    [ <circular> ] dip repeating boa ;

: repeated ( seq length -- new-seq )
    dupd <repeating> swap like ;

M: repeating length len>> ;
M: repeating set-length (>>len) ;

M: repeating virtual@ ( n seq -- n' seq' ) circular>> ;

M: repeating virtual-exemplar circular>> ;

INSTANCE: repeating virtual-sequence
