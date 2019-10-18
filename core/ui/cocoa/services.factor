! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa-ui
USING: alien cocoa io kernel namespaces objc objc-classes
parser prettyprint styles gadgets-listener gadgets-workspace ;

: do-service ( pboard error quot -- )
    pick >r >r
    ?pasteboard-string dup [ r> call ] [ r> 2drop f ] if
    dup [ r> set-pasteboard-string ] [ r> 2drop ] if ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorServiceProvider" }
} {
    "evalInListener:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
    [ nip [ eval-listener f ] do-service 2drop ]
} {
    "evalToString:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
    [ nip [ eval>string ] do-service 2drop ]
} ;

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ;
