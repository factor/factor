! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.syntax kernel kernel.private
math system ;
IN: javascriptcore.ffi.hack

HOOK: set-callstack-bounds os ( -- )

HOOK: macosx-callstack-start-offset cpu ( -- address )
HOOK: macosx-callstack-size-offset cpu ( -- address )

M: ppc macosx-callstack-start-offset HEX: 188 ;
M: ppc macosx-callstack-size-offset HEX: 18c ;

M: x86.32 macosx-callstack-start-offset HEX: c48 ;
M: x86.32 macosx-callstack-size-offset HEX: c4c ;

M: x86.64 macosx-callstack-start-offset HEX: 1860 ;
M: x86.64 macosx-callstack-size-offset HEX: 1868 ;

M: object set-callstack-bounds ;

FUNCTION: void* pthread_self ( ) ;

M: macosx set-callstack-bounds
    callstack-bounds over [ alien-address ] bi@ -
    pthread_self
    [ macosx-callstack-size-offset set-alien-unsigned-cell ]
    [ macosx-callstack-start-offset set-alien-cell ] bi ;
