! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien threads ;
IN: tools.deploy.test.14

: (callback-yield-test) ( -- )
    "void" { } "cdecl" [ yield ] alien-callback
    "void" { } "cdecl" alien-indirect ;

: callback-yield-test ( -- )
    
    "void" { } "cdecl" [
        (callback-yield-test)
    ] alien-callback
    "void" { } "cdecl" alien-indirect ;

MAIN: callback-yield-test