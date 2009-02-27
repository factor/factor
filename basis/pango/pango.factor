! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license
USING: system alien.destructors alien.c-types alien.syntax alien
combinators ;
IN: pango

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Helpful functions from other parts of pango
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<< "pango" {
    { [ os winnt? ] [ "libpango-1.0-0.dll" ] }
    { [ os macosx? ] [ "/opt/local/lib/libpango-1.0.0.dylib" ] }
    { [ os unix? ] [ "libpango-1.0.so" ] }
} cond "cdecl" add-library >>

LIBRARY: pango

CONSTANT: PANGO_SCALE 1024

FUNCTION: PangoContext*
pango_context_new ( ) ;

: dummy-pango-context ( -- context )
    \ dummy-pango-context [ pango_context_new ] initialize-alien ;