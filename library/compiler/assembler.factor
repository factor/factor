! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien generic hashtables kernel kernel-internals lists
math memory namespaces ;

: compiled-base 18 getenv ; inline

: compiled-header HEX: 01c3babe ; inline

: set-compiled-1 ( n a -- ) f swap set-alien-signed-1 ; inline
: set-compiled-4 ( n a -- ) f swap set-alien-signed-4 ; inline
: compiled-cell ( a -- n ) f swap alien-signed-cell ; inline
: set-compiled-cell ( n a -- ) f swap set-alien-signed-cell ; inline

: compile-aligned ( n -- )
    compiled-offset 8 align set-compiled-offset ; inline

: add-literal ( obj -- lit# )
    address literal-top [ set-compiled-cell ] keep
    dup cell get + set-literal-top ;

: assemble-1 ( n -- )
    compiled-offset set-compiled-1
    compiled-offset 1+ set-compiled-offset ; inline

: assemble-4 ( n -- )
    compiled-offset set-compiled-4
    compiled-offset 4 + set-compiled-offset ; inline

: assemble-cell ( n -- )
    compiled-offset set-compiled-cell
    compiled-offset cell get + set-compiled-offset ; inline

: begin-assembly ( -- code-len-fixup reloc-len-fixup )
    compiled-header assemble-cell
    compiled-offset 0 assemble-cell
    compiled-offset 0 assemble-cell ;

: w>h/h dup -16 shift HEX: ffff bitand >r HEX: ffff bitand r> ;
