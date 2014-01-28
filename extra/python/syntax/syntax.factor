USING:
    accessors
    arrays
    effects effects.parser
    formatting
    fry
    generalizations
    kernel
    lexer
    locals
    namespaces
    parser
    python python.ffi
    sequences sequences.generalizations
    vocabs.parser
    words ;
IN: python.syntax

py-initialize

SYMBOL: current-module

: call-or-eval ( args obj -- ret )
    dup PyCallable_Check 1 = [ swap call-object ] [ nip ] if ;

: factor>factor-quot ( py-function effect -- quot )
    [ in>> length ] [ out>> length ] bi swapd '[
        _ narray >py _ call-or-eval >factor
        _ [ 1 = [ 1array ] when ] [ firstn ] bi
    ] ;

: factor>py-quot ( py-function effect -- quot )
    in>> length swap '[ _ narray >py _ call-or-eval ] ;

: py>factor-quot ( py-function effect -- quot )
    [ in>> length ] [ out>> length ] bi swapd '[
        _ narray array>py-tuple _ call-or-eval >factor
        _ [ 1 = [ 1array ] when ] [ firstn ] bi
    ] ;

: py>py-quot ( py-function effect -- quot )
    in>> length swap '[ _ narray array>py-tuple _ call-or-eval ] ;

:: make-function ( basename format effect quot -- )
    basename format sprintf create-in
    current-module get basename getattr
    effect quot [ define-inline ] bi ; inline

:: add-function ( function effect -- )
    function "%s" effect [ factor>factor-quot ] make-function
    function "|%s" effect [ py>factor-quot ] make-function
    function "|%s|" effect in>> { "ret" } <effect> [ py>py-quot ] make-function
    function "%s|" effect in>> { "ret" } <effect> [ factor>py-quot ] make-function
    ; inline

: parse-python-word ( -- )
    scan-token dup ";" = [ drop ] [
        scan-effect add-function parse-python-word
    ] if ; inline recursive

SYNTAX: PY-FROM:
    scan-token import current-module set "=>" expect parse-python-word ; inline
