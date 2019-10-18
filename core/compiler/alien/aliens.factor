! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: bit-arrays byte-arrays assocs io kernel math
namespaces parser sequences generic ;

: <alien> ( address -- alien ) f <displaced-alien> ; inline

: alien>native-string ( alien -- string )
    os { "windows" "wince" } member?
    [ alien>u16-string ] [ alien>char-string ] if ;

: dll-path ( dll -- string )
    (dll-path) alien>native-string ;

M: alien equal?
    over alien? [
        2dup [ expired? ] either? [
            [ expired? ] both?
        ] [
            [ alien-address ] 2apply =
        ] if
    ] [
        2drop f
    ] if ;

SYMBOL: libraries

H{ } clone libraries set-global

TUPLE: library path abi dll ;

C: library ( path abi -- library )
    [ set-library-abi ] keep [ set-library-path ] keep ;

: library ( name -- library ) libraries get at ;

: load-library ( name -- dll )
    library dup [
        dup library-dll [ ] [
            dup library-path dup [
                dlopen dup rot set-library-dll
            ] [
                2drop f
            ] if
        ] ?if
    ] when ;

: add-library ( name path abi -- )
    <library> swap libraries get set-at ;
