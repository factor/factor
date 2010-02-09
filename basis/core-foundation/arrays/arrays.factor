! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax core-foundation kernel
sequences fry ;
IN: core-foundation.arrays

TYPEDEF: void* CFArrayRef

FUNCTION: CFArrayRef CFArrayCreateMutable ( CFAllocatorRef allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( CFArrayRef array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( CFArrayRef array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( CFArrayRef array ) ;

: CF>array ( alien -- array )
    dup CFArrayGetCount
    [ CFArrayGetValueAtIndex ] with { } map-integers ;

: <CFArray> ( seq -- alien )
    f over length &: kCFTypeArrayCallBacks CFArrayCreateMutable
    [ '[ [ _ ] 2dip swap CFArraySetValueAtIndex ] each-index ] keep ;
