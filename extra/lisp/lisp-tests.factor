! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test sequences math kernel parser arrays ;

IN: lisp.test

[
    init-env
    
    [ f ] "#f" lisp-define
    [ t ] "#t" lisp-define
    
    "+" "math" "+" define-primitive
    "-" "math" "-" define-primitive
    
    { 5 } [
      [ 2 3 ] "+" <lisp-symbol> funcall
    ] unit-test
    
    { 8.3 } [
     [ 10.4 2.1 ] "-" <lisp-symbol> funcall
    ] unit-test
    
    { 3 } [
      "((lambda (x y) (+ x y)) 1 2)" lisp-eval
    ] unit-test
    
    { 42 } [
      "((lambda (x y z) (+ x (- y z))) 40 3 1)" lisp-eval
    ] unit-test
    
    { T{ lisp-symbol f "if" } } [
        "(defmacro if (pred tr fl) (quasiquote (cond ((unquote pred) (unquote tr)) (#t (unquote fl)))))" lisp-eval
    ] unit-test
    
    { t } [
        T{ lisp-symbol f "if" } lisp-macro?
    ] unit-test
    
    { 1 } [
      "(if #t 1 2)" lisp-eval
    ] unit-test
    
    { "b" } [
      "(cond (#f \"a\") (#t \"b\"))" lisp-eval
    ] unit-test
    
    { 5 } [
      "(begin (+ 1 4))" lisp-eval
    ] unit-test
    
    { 3 } [
       "((lambda (x) (if x (begin (+ 1 2)) (- 3 5))) #t)" lisp-eval
    ] unit-test
    
] with-interactive-vocabs
