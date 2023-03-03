! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax core-foundation
core-foundation.urls kernel sequences ;
IN: core-foundation.bundles

TYPEDEF: void* CFBundleRef

FUNCTION: CFBundleRef CFBundleCreate ( CFAllocatorRef allocator, CFURLRef bundleURL )

FUNCTION: Boolean CFBundleLoadExecutable ( CFBundleRef bundle )

: <CFBundle> ( string -- bundle )
    t <CFFileSystemURL> [
        f swap CFBundleCreate
    ] keep CFRelease ;

: load-framework ( name -- )
    [ <CFBundle> ]
    [ CFBundleLoadExecutable drop ]
    [ "Cannot load bundle named " prepend throw ] ?if ;
