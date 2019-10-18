! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien math memory kernel hashtables namespaces ;

SYMBOL: interned-literals

: cell 4 ; inline
: compiled-header HEX: 01c3babe ; inline

: compiled-byte ( a -- n )
    <alien> 0 alien-signed-1 ; inline
: set-compiled-byte ( n a -- )
    <alien> 0 set-alien-signed-1 ; inline
: compiled-cell ( a -- n )
    <alien> 0 alien-signed-cell ; inline
: set-compiled-cell ( n a -- )
    <alien> 0 set-alien-signed-cell ; inline

: compile-aligned ( n -- )
    compiled-offset cell 2 * align set-compiled-offset ; inline

: add-literal ( obj -- lit# )
    address
    literal-top set-compiled-cell
    literal-top dup cell + set-literal-top ;

: intern-literal ( obj -- lit# )
    interned-literals get [ add-literal ] cache ;

: compile-byte ( n -- )
    compiled-offset set-compiled-byte
    compiled-offset 1 + set-compiled-offset ; inline

: compile-cell ( n -- )
    compiled-offset set-compiled-cell
    compiled-offset cell + set-compiled-offset ; inline

: begin-assembly ( -- code-len-fixup reloc-len-fixup )
    compiled-header compile-cell
    compiled-offset 0 compile-cell
    compiled-offset 0 compile-cell ;

: init-assembler ( -- )
    {{ }} clone interned-literals global set-hash ;

: w>h/h dup -16 shift HEX: ffff bitand >r HEX: ffff bitand r> ;
