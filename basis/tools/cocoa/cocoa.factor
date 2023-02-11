! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: cocoa.messages cocoa.runtime combinators
combinators.smart kernel prettyprint ;
IN: tools.cocoa

: method. ( method -- )
    [
        {
            [ method_getName sel_getName ]
            [ method-return-type ]
            [ method-arg-types ]
            [ method_getImplementation ]
        } cleave
    ] output>array . ;

: methods. ( class -- )
    [ nip method. ] each-method-in-class ;
