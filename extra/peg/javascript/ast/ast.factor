! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: peg.javascript.ast

TUPLE: ast-keyword value ;
TUPLE: ast-name value ;
TUPLE: ast-number value ;
TUPLE: ast-string value ;
TUPLE: ast-regexp body flags ;
TUPLE: ast-cond-expr condition then else ;
TUPLE: ast-set lhs rhs ;
TUPLE: ast-get value ;
TUPLE: ast-mset lhs rhs operator ;
TUPLE: ast-binop lhs rhs operator ;
TUPLE: ast-unop expr operator ;
TUPLE: ast-postop expr operator ;
TUPLE: ast-preop expr operator ;
TUPLE: ast-getp index expr ;
TUPLE: ast-send method expr args ;
TUPLE: ast-call expr args ;
TUPLE: ast-this ;
TUPLE: ast-new name args ;
TUPLE: ast-array values ;
TUPLE: ast-json bindings ;
TUPLE: ast-binding name value ;
TUPLE: ast-func fs body ;
TUPLE: ast-var name value ;
TUPLE: ast-begin statements ;
TUPLE: ast-if condition true false ;
TUPLE: ast-while condition statements ;
TUPLE: ast-do-while statements condition ;
TUPLE: ast-for i c u statements ;
TUPLE: ast-for-in v e statements ;
TUPLE: ast-switch expr statements ;
TUPLE: ast-break ;
TUPLE: ast-continue ;
TUPLE: ast-throw e ;
TUPLE: ast-try t e c f ;
TUPLE: ast-return e ;
TUPLE: ast-with expr body ;
TUPLE: ast-case c cs ;
TUPLE: ast-default cs ;
