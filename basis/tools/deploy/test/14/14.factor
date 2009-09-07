! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct cocoa cocoa.classes
cocoa.subclassing core-graphics.types kernel math ;
IN: tools.deploy.test.14

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Foo" }
} {
    "foo:"
    "float"
    { "id" "SEL" "NSRect" }
    [
        [ origin>> [ x>> ] [ y>> ] bi + ]
        [ size>> [ w>> ] [ h>> ] bi + ]
        bi +
    ]
} ;

: main ( -- )
    Foo -> alloc -> init
    S{ CGRect f S{ CGPoint f 1.0 2.0 } S{ CGSize f 3.0 4.0 } } -> foo:
    10.0 assert= ;

MAIN: main
