! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: arrays system alien.destructors alien.c-types alien.syntax alien
combinators math.rectangles kernel math alien.libraries classes.struct
accessors ;
IN: pango

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Helpful functions from other parts of pango
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<< {
    { [ os winnt? ] [ "pango" "libpango-1.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "pango" "/opt/local/lib/libpango-1.0.0.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ ] }
} cond >>

LIBRARY: pango

CONSTANT: PANGO_SCALE 1024

: pango>float ( n -- x ) PANGO_SCALE /f ; inline
: float>pango ( x -- n ) PANGO_SCALE * >integer ; inline

TYPEDEF: void* PangoContext*

FUNCTION: PangoContext* pango_context_new ( ) ;

STRUCT: PangoRectangle
    { x int }
    { y int }
    { width int }
    { height int } ;

: PangoRectangle>rect ( PangoRectangle -- rect )
    [ [ x>> pango>float ] [ y>> pango>float ] bi 2array ]
    [ [ width>> pango>float ] [ height>> pango>float ] bi 2array ] bi
    <rect> ;
