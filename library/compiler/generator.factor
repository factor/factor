! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: compiler
USE: assembler
USE: inference
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings
USE: words
USE: vectors

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get vector-push ;

: relocating compiled-offset cell - rel, ;

: rel-primitive ( word rel/abs -- )
    #! If flag is true; relative.
    0 1 ? rel, relocating word-primitive rel, ;

: rel-word ( word rel/abs -- )
    #! If flag is true; relative.
    over primitive? [ rel-primitive ] [ 2drop ] ifte ;

: rel-dlsym ( name dll rel/abs -- )
    #! If flag is true; relative.
    2 3 ? rel, relocating cons intern-literal rel, ;

: rel-address ( -- )
    #! Relocate address just compiled.
    4 rel, relocating 0 rel, ;

: generate-node ( [ op | params ] -- )
    #! Generate machine code for a node.
    unswons dup "generator" word-property [
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

#label [ save-xt ] "generator" set-word-property

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;
