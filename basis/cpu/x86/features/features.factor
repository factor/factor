! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel memoize math math.order math.parser
namespaces alien.c-types alien.syntax combinators locals init io
compiler compiler.units accessors ;
IN: cpu.x86.features

<PRIVATE

FUNCTION: int sse_version ( ) ;

FUNCTION: longlong read_timestamp_counter ( ) ;

PRIVATE>

: sse-version ( -- n )
    sse_version
    "sse-version" get string>number [ min ] when* ; foldable

: sse? ( -- ? ) sse-version 10 >= ; foldable
: sse2? ( -- ? ) sse-version 20 >= ; foldable
: sse3? ( -- ? ) sse-version 30 >= ; foldable
: ssse3? ( -- ? ) sse-version 33 >= ; foldable
: sse4.1? ( -- ? ) sse-version 41 >= ; foldable
: sse4.2? ( -- ? ) sse-version 42 >= ; foldable

: sse-string ( version -- string )
    {
        { 00 [ "no SSE" ] }
        { 10 [ "SSE1" ] }
        { 20 [ "SSE2" ] }
        { 30 [ "SSE3" ] }
        { 33 [ "SSSE3" ] }
        { 41 [ "SSE4.1" ] }
        { 42 [ "SSE4.2" ] }
    } case ;

HOOK: instruction-count cpu ( -- n )

M: x86 instruction-count read_timestamp_counter ;

: count-instructions ( quot -- n )
    instruction-count [ call ] dip instruction-count swap - ; inline
