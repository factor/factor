! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays hashtables io kernel lists math namespaces parser
sequences ;

! USAGE:
! 
! Command line parameters given to the runtime specify libraries
! to load.
!
! -libraries:<foo>:name=<soname> -- define a library <foo>, to be
! loaded from the <soname> DLL.
!
! -libraries:<foo>:abi=stdcall -- define a library using the
! stdcall ABI. This ABI is usually used on Win32. Any other abi
! parameter, or a missing abi parameter indicates the cdecl ABI
! should be used, which is common on Unix.

UNION: c-ptr byte-array alien displaced-alien ;

M: alien hashcode ( obj -- n ) alien-address >fixnum ;

M: alien = ( obj obj -- ? )
    over alien? [ [ alien-address ] 2apply = ] [ 2drop f ] if ;

global [ "libraries" nest drop ] bind

: library ( name -- object ) "libraries" get hash ;

: load-library ( name -- dll )
    #! Higher level wrapper around dlopen primitive.
    library dup [
        [
            "dll" get dup [
                drop "name" get dlopen dup "dll" set
            ] unless
        ] bind
    ] when ;

: add-library ( library name abi -- )
    "libraries" get [
        [ "abi" set "name" set ] make-hash swap set
    ] bind ;

: add-simple-library ( name file -- ) 
    os "win32" = ".dll" ".so" ? append
    os "win32" = "stdcall" "cdecl" ? add-library ;

: library-abi ( library -- abi )
    library "abi" swap ?hash [ "cdecl" ] unless* ;
