! Copyright (C) 2005, 2006 Kevin Reid.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-classes
DEFER: FactorCallback

IN: cocoa-callbacks
USING: gadgets hashtables kernel namespaces objc cocoa ;

SYMBOL: callbacks

: reset-callbacks ( -- )
    H{ } clone callbacks set-global ;

reset-callbacks

"NSObject" "FactorCallback" {
    { "perform:" "void" { "id" "SEL" "id" }
        [ 2drop callbacks get hash ui-try ]
    }
    
    { "dealloc" "void" { "id" "SEL" }
        [
            drop
            dup callbacks get remove-hash
            SUPER-> dealloc
        ]
    }
} define-objc-class

: <FactorCallback> ( quot -- id )
    FactorCallback -> alloc -> init
    [ callbacks get set-hash ] keep ;

PROVIDE: callbacks ;
