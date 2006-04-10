! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien kernel math ;

BEGIN-STRUCT: NSRect
    FIELD: float x
    FIELD: float y
    FIELD: float w
    FIELD: float h
END-STRUCT

TYPEDEF: NSRect _NSRect
TYPEDEF: NSRect CGRect

: <NSRect>
    "NSRect" <c-object>
    [ set-NSRect-h ] keep
    [ set-NSRect-w ] keep
    [ set-NSRect-y ] keep
    [ set-NSRect-x ] keep ;

: NSRect-x-y ( rect -- origin-x origin-y )
    [ NSRect-x ] keep NSRect-y ;

: NSRect-x-far-y ( rect -- origin-x far-y )
    [ NSRect-x-y ] keep NSRect-h + ;
  
: <far-y-NSRect> ( x y w h -- rect )
    rot dupd swap - -rot <NSRect> ;

BEGIN-STRUCT: NSPoint
    FIELD: float x
    FIELD: float y
END-STRUCT

TYPEDEF: NSPoint _NSPoint
TYPEDEF: NSPoint CGPoint

: <NSPoint>
    "NSPoint" <c-object>
    [ set-NSPoint-y ] keep
    [ set-NSPoint-x ] keep ;

BEGIN-STRUCT: NSSize
    FIELD: float w
    FIELD: float h
END-STRUCT

TYPEDEF: NSSize _NSSize
TYPEDEF: NSPoint CGPoint

: <NSSize>
    "NSSize" <c-object>
    [ set-NSSize-h ] keep
    [ set-NSSize-w ] keep ;
