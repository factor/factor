! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
IN: infix.ast

TUPLE: ast-value value ;
TUPLE: ast-local name ;
TUPLE: ast-array name index ;
TUPLE: ast-slice name from to step ;
TUPLE: ast-function name arguments ;
TUPLE: ast-op left right op ;
TUPLE: ast-negation term ;
