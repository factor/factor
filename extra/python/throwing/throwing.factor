USING: arrays kernel python python.ffi python.syntax sequences ;
IN: python.throwing

PY-FROM: traceback => format_tb ( tb -- seq ) ;

PY-METHODS: obj =>
    __name__ ( o -- str )
    __str__ ( o -- str ) ;

: throw-error ( ptype pvalue ptraceback -- )
    [
        [ $__name__ py> ]
        [ __str__ py> ]
        [ [ format_tb py> ] [ f ] if* ] tri*
    ] 3keep
    [ Py_DecRef ] tri@ python-error ;
