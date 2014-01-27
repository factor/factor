USING: alien arrays kernel namespaces python ;
IN: python.stdlib.builtin

py-initialize

SYMBOL: builtin

builtin [ "__builtin__" import ] initialize

: repr ( alien/factor -- py-str )
    dup alien? [ >py ] unless
    <1py-tuple> builtin get "repr" getattr swap call-object ;

: range ( n -- py-list )
    builtin get "range" getattr swap 1array >py call-object ;
