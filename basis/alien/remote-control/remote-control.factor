! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.strings parser
threads words kernel.private kernel io.encodings.utf8 eval ;
IN: alien.remote-control

: eval-callback ( -- callback )
    "void*" { "char*" } "cdecl"
    [ eval>string utf8 malloc-string ] alien-callback ;

: yield-callback ( -- callback )
    "void" { } "cdecl" [ yield ] alien-callback ;

: sleep-callback ( -- callback )
    "void" { "long" } "cdecl" [ sleep ] alien-callback ;

: ?callback ( word -- alien )
    dup optimized? [ execute ] [ drop f ] if ; inline

: init-remote-control ( -- )
    \ eval-callback ?callback 16 setenv
    \ yield-callback ?callback 17 setenv
    \ sleep-callback ?callback 18 setenv ;

MAIN: init-remote-control
