! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler compiler-backend kernel lists math namespaces
sequences words ;

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
    1 rel-type, relocating cons add-literal rel, ;

: rel-address ( rel/abs 16/16 -- )
    #! Relocate address just compiled.
    over 1 = [ 2drop ] [ 2 rel-type, relocating 0 rel, ] if ;

: rel-word ( word rel/abs 16/16 -- )
    pick primitive? [ rel-primitive ] [ rel-address drop ] if ;

: rel-userenv ( n 16/16 -- )
    0 swap 3 rel-type, relocating rel, ;

: rel-cards ( 16/16 -- )
    0 swap 4 rel-type, compiled-offset cell 2 * - rel, 0 rel, ;
