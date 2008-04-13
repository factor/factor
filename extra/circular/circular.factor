! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http;//factorcode.org/license.txt for BSD license
USING: kernel sequences math sequences.private strings
accessors ;
IN: circular

! a circular sequence wraps another sequence, but begins at an
! arbitrary element in the underlying sequence.
TUPLE: circular seq start ;

: <circular> ( seq -- circular )
    0 circular construct-boa ;

: circular-wrap ( n circular -- n circular )
    [ start>> + ] keep
    [ seq>> length rem ] keep ; inline

M: circular length seq>> length ;

M: circular virtual@ circular-wrap seq>> ;

M: circular nth virtual@ nth ;

M: circular set-nth virtual@ set-nth ;

M: circular virtual-seq seq>> ;

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    circular-wrap (>>start) ;

: push-circular ( elt circular -- )
    [ set-first ] [ 1 swap change-circular-start ] bi ;

: <circular-string> ( n -- circular )
    0 <string> <circular> ;

INSTANCE: circular virtual-sequence
