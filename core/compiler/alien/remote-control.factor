! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien parser threads words kernel-internals kernel ;
IN: remote-control

: eval-callback
    "void*" { "char*" } "cdecl"
    [ eval>string malloc-char-string ] alien-callback ;

: yield-callback
    "void" { } "cdecl" [ yield ] alien-callback ;

: eval-callback* ( -- alien )
    \ eval-callback compiled? [ eval-callback ] [ f ] if ;

: yield-callback* ( -- alien )
    \ yield-callback compiled? [ yield-callback ] [ f ] if ;

IN: shells

: remote-control ( -- )
    eval-callback* 15 setenv
    yield-callback* 18 setenv ;
