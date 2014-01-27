USING: kernel namespaces python ;
IN: python.stdlib.sys

py-initialize

SYMBOL: sys
sys [ "sys" import ] initialize

: getrefcount ( alien -- py-int )
    <1py-tuple> sys get "getrefcount" getattr swap call-object ;
