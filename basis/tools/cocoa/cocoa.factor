! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays cocoa.messages cocoa.runtime combinators
prettyprint ;
IN: tools.cocoa

: method. ( method -- )
    {
        [ method_getName sel_getName ]
        [ method-return-type ]
        [ method-arg-types ]
        [ method_getImplementation ]
    } cleave 4array . ;

: methods. ( class -- )
    [ method. ] each-method-in-class ;
