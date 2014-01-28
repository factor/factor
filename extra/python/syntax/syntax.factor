USING: accessors arrays effects effects.parser fry generalizations
kernel lexer locals math namespaces parser python python.ffi sequences
sequences.generalizations vocabs.parser words ;
IN: python.syntax

py-initialize

SYMBOL: current-module

: call-or-eval ( args obj -- ret )
    dup PyCallable_Check 1 = [ swap call-object ] [ nip ] if ;

:: add-function ( function effect -- )
    function create-in
    effect [ in>> length ] [ out>> length ] bi
    current-module get function getattr swap
    '[
        _ narray array>py-tuple _ call-or-eval
        _ [ 0 = [ drop 0 <py-tuple> ] when ] keep
        [ 1 = [ <1py-tuple> ] when ] keep
        [ py-tuple>array ] dip firstn
    ] effect define-inline ; inline

: parse-python-word ( -- )
    scan-token dup ";" = [ drop ] [
        scan-effect add-function parse-python-word
    ] if ; inline recursive

SYNTAX: PY-FROM:
    scan-token import current-module set "=>" expect parse-python-word ; inline

:: add-method ( attr effect -- )
    attr "->" prepend create-in
    effect [ in>> length 1 - ] [ out>> length ] bi

    '[ _ narray array>py-tuple swap attr getattr swap call-object
       _ [ 1 = [ 1array ] when ] [ firstn ] bi ]


    ! '[ attr getattr _ narray array>py-tuple call-object
    !    _ [ 1 = [ 1array ] when ] [ firstn ] bi ]
    effect define-inline ;

: parse-python-method ( -- )
    scan-token dup ";" = [ drop ] [
        scan-effect add-method parse-python-method
    ] if ; inline recursive

SYNTAX: PY-METHODS:
    scan-token drop "=>" expect parse-python-method ; inline
