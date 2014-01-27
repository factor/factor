USING: alien arrays kernel namespaces python ;
IN: python.stdlib.builtin

py-initialize

SYMBOL: builtin

builtin [ "__builtin__" import ] initialize

: simple-call ( arg func-name -- return )
    builtin get swap getattr swap <1py-tuple> call-object ;

: repr ( alien/factor -- py-str )
    dup alien? [ >py ] unless "repr" simple-call ;

: range ( n -- py-list )
    >py "range" simple-call ;

: dir ( obj -- py-list )
    "dir" simple-call ;

: type ( obj -- py-obj )
    "type" simple-call ;

: callable ( obj -- py-obj )
    "callable" simple-call ;
