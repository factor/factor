! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel math alien.syntax ;
IN: cpu.x86.features

<PRIVATE

FUNCTION: bool check_sse2 ( ) ;

FUNCTION: longlong read_timestamp_counter ( ) ;

PRIVATE>

HOOK: sse2? cpu ( -- ? )

M: x86.32 sse2? check_sse2 ;

M: x86.64 sse2? t ;

HOOK: instruction-count cpu ( -- n )

M: x86 instruction-count read_timestamp_counter ;

: count-instructions ( quot -- n )
    instruction-count [ call ] dip instruction-count swap - ; inline
