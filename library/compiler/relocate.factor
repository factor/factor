! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler kernel lists math namespaces sequences words ;

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get push ;

: relocating compiled-offset cell - rel, ;

: rel-primitive ( word rel/abs -- )
    #! If flag is true; relative.
    0 1 ? rel, relocating word-primitive rel, ;

: rel-dlsym ( name dll rel/abs -- )
    #! If flag is true; relative.
    2 3 ? rel, relocating cons intern-literal rel, ;

: rel-address ( rel/abs -- )
    #! Relocate address just compiled. If flag is true,
    #! relative, and there is nothing to do.
    [ 4 rel, relocating 0 rel, ] unless ;

: rel-word ( word rel/abs -- )
    #! If flag is true; relative.
    over primitive? [ rel-primitive ] [ nip rel-address ] ifte ;

! PowerPC relocations

: rel-primitive-16/16 ( word -- )
    #! This is called before a sequence like
    #! 19 LOAD32
    #! 19 MTCTR
    #! BCTR
    5 rel, compiled-offset rel, word-primitive rel, ;

: rel-dlsym-16/16 ( name dll -- )
    6 rel, compiled-offset rel, cons intern-literal rel, ;

: rel-address-16/16 ( -- )
    7 rel, compiled-offset rel, 0 rel, ;
