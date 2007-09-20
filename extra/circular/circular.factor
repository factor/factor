! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http;//factorcode.org/license.txt for BSD license
USING: kernel sequences math sequences.private strings ;
IN: circular

! a circular sequence wraps another sequence, but begins at an
! arbitrary element in the underlying sequence.
TUPLE: circular seq start ;

: <circular> ( seq -- circular )
    0 circular construct-boa ;

: circular-wrap ( n circular -- n circular )
    [ circular-start + ] keep
    [ circular-seq length rem ] keep ; inline

M: circular length circular-seq length ;

M: circular virtual@ circular-wrap circular-seq ;

M: circular nth bounds-check virtual@ nth ;

M: circular set-nth bounds-check virtual@ set-nth ;

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    circular-wrap set-circular-start ;

: push-circular ( elt circular -- )
    [ set-first ] keep 1 swap change-circular-start ;

: <circular-string> ( n -- circular )
    0 <string> <circular> ;

M: circular virtual-seq circular-seq ;

INSTANCE: circular virtual-sequence
