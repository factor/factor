! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien kernel ;

BEGIN-STRUCT: NSRect
    FIELD: float x
    FIELD: float y
    FIELD: float w
    FIELD: float h
END-STRUCT

TYPEDEF: NSRect _NSRect

: <NSRect>
    "NSRect" <c-object>
    [ set-NSRect-h ] keep
    [ set-NSRect-w ] keep
    [ set-NSRect-y ] keep
    [ set-NSRect-x ] keep ;

BEGIN-STRUCT: NSPoint
    FIELD: float x
    FIELD: float y
END-STRUCT

TYPEDEF: NSPoint _NSPoint

: <NSPoint>
    "NSPoint" <c-object>
    [ set-NSPoint-y ] keep
    [ set-NSPoint-x ] keep ;

BEGIN-STRUCT: NSSize
    FIELD: float w
    FIELD: float h
END-STRUCT

TYPEDEF: NSSize _NSSize

: <NSSize>
    "NSSize" <c-object>
    [ set-NSSize-h ] keep
    [ set-NSSize-w ] keep ;
