! Copyright (C) 2005, 2006 Kevin Reid.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces cocoa cocoa.classes
cocoa.subclassing debugger ;
IN: cocoa.callbacks

SYMBOL: callbacks

: reset-callbacks ( -- )
    H{ } clone callbacks set-global ;

reset-callbacks

CLASS: {
    { +name+ "FactorCallback" }
    { +superclass+ "NSObject" }
}

{ "perform:" void { id SEL id }
    [ 2drop callbacks get at try ]
}

{ "dealloc" void { id SEL }
    [
        drop
        dup callbacks get delete-at
        SUPER-> dealloc
    ]
} ;

: <FactorCallback> ( quot -- id )
    FactorCallback -> alloc -> init
    [ callbacks get set-at ] keep ;
