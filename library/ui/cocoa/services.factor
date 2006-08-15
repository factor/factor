! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc-classes
DEFER: FactorServiceProvider

IN: cocoa
USING: alien gadgets-presentations io kernel namespaces objc
parser prettyprint styles ;

: pasteboard-error ( error str -- f )
    "Pasteboard does not hold a string" <NSString>
    0 swap rot set-void*-nth f ;

: ?pasteboard-string ( pboard error -- str/f )
    over pasteboard-string? [
        swap pasteboard-string [ ] [ pasteboard-error ] ?if
    ] [
        nip pasteboard-error
    ] if ;

: do-service ( pboard error quot -- )
    pick >r >r
    ?pasteboard-string dup [ r> call ] [ r> 2drop f ] if
    dup [ r> set-pasteboard-string ] [ r> 2drop ] if ;

"NSObject" "FactorServiceProvider" {
    {
        "evalInListener:userData:error:" "void"
        { "id" "SEL" "id" "id" "void*" }
        [ nip [ <input> show f ] do-service 2drop ]
    }
    {
        "evalToString:userData:error:" "void"
        { "id" "SEL" "id" "id" "void*" }
        [ nip [ eval>string ] do-service 2drop ]
    }
} { } define-objc-class

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;
