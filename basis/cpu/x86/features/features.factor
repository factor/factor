! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel math math.order math.parser namespaces
alien.c-types alien.syntax combinators locals init io cpu.x86
compiler compiler.units accessors ;
IN: cpu.x86.features

<PRIVATE

FUNCTION: int sse_version ( ) ;

FUNCTION: longlong read_timestamp_counter ( ) ;

PRIVATE>

ALIAS: sse-version sse_version

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

USING: cpu.x86.features cpu.x86.features.private ;

:: install-sse-check ( version -- )
    [
        sse-version version < [
            "This image was built to use " write
            version sse-string write
            " but your CPU only supports " write
            sse-version sse-string write "." print
            "You will need to bootstrap Factor again." print
            flush
            1 exit
        ] when
    ] "cpu.x86" add-init-hook ;

: enable-sse ( version -- )
    {
        { 00 [ ] }
        { 10 [ ] }
        { 20 [ enable-sse2 ] }
        { 30 [ enable-sse3 ] }
        { 33 [ enable-sse3 ] }
        { 41 [ enable-sse3 ] }
        { 42 [ enable-sse3 ] }
    } case ;

[ { sse_version } compile ] with-optimizer

"Checking for multimedia extensions: " write sse-version
"sse-version" get [ string>number min ] when*
[ sse-string write " detected" print ]
[ install-sse-check ]
[ enable-sse ] tri
