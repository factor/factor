! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct cocoa cocoa.classes
cocoa.runtime cocoa.subclassing cocoa.types core-graphics.types
kernel math ;
FROM: alien.c-types => float ;
IN: tools.deploy.test.14

<CLASS: Bar < NSObject
    COCOA-METHOD: float bar: NSRect rect [
        rect origin>> [ x>> ] [ y>> ] bi +
        rect size>> [ w>> ] [ h>> ] bi +
        +
    ] ;
;CLASS>

: main ( -- )
    Bar send: alloc send: init
    S{ CGRect f S{ CGPoint f 1.0 2.0 } S{ CGSize f 3.0 4.0 } } send: \bar:
    10.0 assert= ;

MAIN: main
