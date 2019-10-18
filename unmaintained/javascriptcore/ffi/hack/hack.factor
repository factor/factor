! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.c-types alien.syntax kernel
kernel.private math system ;
IN: javascriptcore.ffi.hack

HOOK: set-callstack-bounds os ( -- )

HOOK: macosx-callstack-start-offset cpu ( -- address )
HOOK: macosx-callstack-size-offset cpu ( -- address )

M: ppc macosx-callstack-start-offset 0x188 ;
M: ppc macosx-callstack-size-offset 0x18c ;

M: x86.32 macosx-callstack-start-offset 0xc48 ;
M: x86.32 macosx-callstack-size-offset 0xc4c ;

M: x86.64 macosx-callstack-start-offset 0x1860 ;
M: x86.64 macosx-callstack-size-offset 0x1868 ;

M: object set-callstack-bounds ;

FUNCTION: void* pthread_self ( ) ;

M: macosx set-callstack-bounds
    callstack-bounds over [ alien-address ] bi@ -
    pthread_self
    [ macosx-callstack-size-offset set-alien-unsigned-cell ]
    [ macosx-callstack-start-offset set-alien-cell ] bi ;
