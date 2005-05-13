! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler kernel lists math namespaces sequences words ;

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get push ;

: relocating compiled-offset cell - rel, ;

: rel-type, ( rel/abs 16/16 type -- )
    swap 8 shift bitor swap 16 shift bitor rel, ;

: rel-primitive ( word relative 16/16 -- )
    0 rel-type, relocating word-primitive rel, ;

: rel-dlsym ( name dll rel/abs 16/16 -- )
    1 rel-type, relocating cons intern-literal rel, ;

: rel-address ( rel/abs 16/16 -- )
    #! Relocate address just compiled. If flag is true,
    #! relative, and there is nothing to do.
    over [ 2drop ] [ 2 rel-type, relocating 0 rel, ] ifte ;

: rel-word ( word rel/abs 16/16 -- )
    #! If flag is true; relative.
    over primitive? [ rel-primitive ] [ nip rel-address ] ifte ;
