! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: enchilada
USING: generic kernel enchilada.engine enchilada.parser enchilada.printer prettyprint ; 


: (e-eval) ( e-expression -- )
    dup e-reducible? [ dup e-print . e-reduce (e-eval) ] [ e-print . ] if ;

: e-eval ( string -- )
    e-parse (e-eval) ;
