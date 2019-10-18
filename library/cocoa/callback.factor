IN: objc-FactorCallback
DEFER: FactorCallback

IN: cocoa
USING: hashtables kernel namespaces objc objc-NSObject ;

SYMBOL: callbacks

H{ } clone callbacks set

"NSObject" "FactorCallback" {
    { "perform:" "void" { "id" "SEL" "id" }
        [ nip swap callbacks get hash call ]
    }
    
    { "dealloc" "void" { "id" "SEL" }
        [
            drop
            dup callbacks get remove-hash
            SUPER-> [dealloc]
        ]
    }
} { } define-objc-class

: <FactorCallback> ( quot -- id | quot: id -- )
    FactorCallback [alloc] [init]
    [ callbacks get set-hash ] keep ;