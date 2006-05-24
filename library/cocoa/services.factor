IN: objc-FactorServiceProvider
DEFER: FactorServiceProvider

IN: cocoa
USING: alien gadgets-presentations kernel objc
objc-NSApplication objc-NSObject parser styles ;

: pasteboard-error ( error str -- f )
    "Pasteboard does not hold a string" <NSString>
    0 rot set-void*-nth f ;

: ?pasteboard-string ( pboard error -- str/f )
    NSStringPboardType pick pasteboard-type? [
        swap pasteboard-string [ ] [ pasteboard-error ] ?if
    ] [
        nip pasteboard-error
    ] if ;

: do-service ( pboard error quot -- | quot: str -- str/f )
    [
        >r ?pasteboard-string dup [ r> call ] [ r> 2drop ] if
    ] keep over [ set-pasteboard-string ] [ 2drop ] if ;

"NSObject" "FactorServiceProvider" {
    { "evalInListener:" "void" { "id" "SEL" "id" "id" "void*" }
        [ nip [ <input> f show-object f ] do-service ]
    }
    { "evalToString:" "void" { "id" "SEL" "id" "id" "void*" }
        [ nip [ eval>string ] do-service ]
    }
} { } define-objc-class

: register-services ( -- )
    NSApp
    FactorServiceProvider [alloc] [init]
    [setServicesProvider:] ;
