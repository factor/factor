! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference errors kernel lists math namespaces
strings words vectors ;

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get vector-push ;

: relocating compiled-offset cell - rel, ;

: rel-primitive ( word rel/abs -- )
    #! If flag is true; relative.
    0 1 ? rel, relocating word-primitive rel, ;

: rel-dlsym ( name dll rel/abs -- )
    #! If flag is true; relative.
    2 3 ? rel, relocating cons intern-literal rel, ;

: rel-address ( -- )
    #! Relocate address just compiled.
    4 rel, relocating 0 rel, ;

: rel-word ( word rel/abs -- )
    #! If flag is true; relative.
    over primitive? [
        rel-primitive
    ] [
        nip [ rel-address ] unless
    ] ifte ;

: generate-node ( [[ op params ]] -- )
    #! Generate machine code for a node.
    unswons dup "generator" word-prop [
        call
    ] [
        "No generator" throw
    ] ?ifte ;

: generate-code ( word linear -- length )
    compiled-offset >r
    compile-aligned
    swap save-xt
    [ generate-node ] each
    compile-aligned
    compiled-offset r> - ;

: generate-reloc ( -- length )
    relocation-table get
    dup [ compile-cell ] vector-each
    vector-length cell * ;

: (generate) ( word linear -- )
    #! Compile a word definition from linear IR.
    100 <vector> relocation-table set
    begin-assembly swap >r >r
        generate-code
        generate-reloc
    r> set-compiled-cell
    r> set-compiled-cell ;

SYMBOL: previous-offset

: generate ( word linear -- )
    #! If generation fails, reset compiled offset.
    [
        compiled-offset previous-offset set
        (generate)
    ] [
        [
            previous-offset get set-compiled-offset
            rethrow
        ] when*
    ] catch ;

#label [ save-xt ] "generator" set-word-prop

#end-dispatch [ drop ] "generator" set-word-prop

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;
