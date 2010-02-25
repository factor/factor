! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
parser threads words kernel.private kernel io.encodings.utf8
eval ;
IN: alien.remote-control

: eval-callback ( -- callback )
    void* { c-string } "cdecl"
    [ eval>string utf8 malloc-string ] alien-callback ;

: yield-callback ( -- callback )
    void { } "cdecl" [ yield ] alien-callback ;

: sleep-callback ( -- callback )
    void { long } "cdecl" [ sleep ] alien-callback ;

: ?callback ( word -- alien )
    dup optimized? [ execute ] [ drop f ] if ; inline

: init-remote-control ( -- )
    \ eval-callback ?callback 16 set-special-object
    \ yield-callback ?callback 17 set-special-object
    \ sleep-callback ?callback 18 set-special-object ;

MAIN: init-remote-control
