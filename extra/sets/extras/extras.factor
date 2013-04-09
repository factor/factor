! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sets ;
IN: sets.extras

: setwise-xor ( seq1 seq2 -- set )
    [ append members ] [ intersect ] 2bi diff ;

: symmetric-diff ( set1 set2 -- set )
    [ union ] [ intersect ] 2bi diff ;

: proper-subset? ( set1 set2 -- ? )
    2dup subset? [ swap subset? not ] [ 2drop f ] if ;
