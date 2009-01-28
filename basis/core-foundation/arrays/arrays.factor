! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel sequences ;
IN: core-foundation.arrays

TYPEDEF: void* CFArrayRef

FUNCTION: CFArrayRef CFArrayCreateMutable ( CFAllocatorRef allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( CFArrayRef array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( CFArrayRef array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( CFArrayRef array ) ;

: CF>array ( alien -- array )
    dup CFArrayGetCount [ CFArrayGetValueAtIndex ] with map ;

: <CFArray> ( seq -- alien )
    [ f swap length f CFArrayCreateMutable ] keep
    [ length ] keep
    [ [ dupd ] dip CFArraySetValueAtIndex ] 2each ;
