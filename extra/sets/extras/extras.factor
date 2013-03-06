! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sets ;
IN: sets.extras

: setwise-xor ( seq0 seq1 -- set )
    [ append members ] [ intersect ] 2bi diff ;
