! Copyright (C) 2005, 2006 Kevin Reid.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: core/cocoa ;

IN: cocoa-callbacks
USING: gadgets assocs kernel namespaces objc objc-classes
cocoa ;

SYMBOL: callbacks

: reset-callbacks ( -- )
    H{ } clone callbacks set-global ;

reset-callbacks

CLASS: {
    { +name+ "FactorCallback" }
    { +superclass+ "NSObject" }
}

{ "perform:" "void" { "id" "SEL" "id" }
    [ 2drop callbacks get at ui-try ]
}

{ "dealloc" "void" { "id" "SEL" }
    [
        drop
        dup callbacks get delete-at
        SUPER-> dealloc
    ]
} ;

: <FactorCallback> ( quot -- id )
    FactorCallback -> alloc -> init
    [ callbacks get set-at ] keep ;

PROVIDE: libs/cocoa-callbacks ;
