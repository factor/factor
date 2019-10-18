! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays cocoa.messages cocoa.runtime combinators
prettyprint combinators.smart ;
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
    [ method. ] each-method-in-class ;
