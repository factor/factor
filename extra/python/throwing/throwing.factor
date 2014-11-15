USING: arrays kernel python python.ffi python.modules.__builtin__ python.syntax
sequences ;
IN: python.throwing

PY-FROM: traceback => format_tb ( tb -- seq ) ;

: throw-error ( ptype pvalue ptraceback -- )
    [
        [ $__name__ py> ]
        [ __str__ py> ]
        [ [ format_tb py> ] [ f ] if* ] tri*
    ] 3keep
    [ Py_DecRef ] tri@ python-error ;
