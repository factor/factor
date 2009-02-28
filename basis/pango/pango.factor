! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: arrays system alien.destructors alien.c-types alien.syntax alien
combinators math.rectangles kernel ;
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

C-STRUCT: PangoRectangle
    { "int" "x" }
    { "int" "y" }
    { "int" "width" }
    { "int" "height" } ;

: PangoRectangle>rect ( PangoRectangle -- rect )
    [ [ PangoRectangle-x ] [ PangoRectangle-y ] bi 2array ]
    [ [ PangoRectangle-width ] [ PangoRectangle-height ] bi 2array ] bi
    <rect> ;

: dummy-pango-context ( -- context )
    \ dummy-pango-context [ pango_context_new ] initialize-alien ;