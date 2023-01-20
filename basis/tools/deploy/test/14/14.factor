! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct cocoa cocoa.classes
cocoa.runtime cocoa.subclassing cocoa.types core-graphics.types
kernel math ;
FROM: alien.c-types => float ;
IN: tools.deploy.test.14

<CLASS: Bar < NSObject
    METHOD: float bar: NSRect rect [
        rect origin>> [ x>> ] [ y>> ] bi +
        rect size>> [ w>> ] [ h>> ] bi +
        +
    ] ;
;CLASS>

: main ( -- )
    Bar -> alloc -> init
    S{ CGRect f S{ CGPoint f 1.0 2.0 } S{ CGSize f 3.0 4.0 } } -> bar:
    10.0 assert= ;

MAIN: main
