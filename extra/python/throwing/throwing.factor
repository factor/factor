USING: arrays kernel python python.syntax sequences ;
IN: python.throwing

ERROR: python-error type message traceback ;

PY-FROM: traceback => format_tb ( tb -- seq ) ;

PY-METHODS: obj =>
    __name__ ( o -- str )
    __str__ ( o -- str ) ;

: throw-error ( ptype pvalue ptraceback -- )
    [ $__name__ py> ] [ __str__ py> ] [ [ format_tb py> ] [ f ] if* ] tri*
    python-error ;
