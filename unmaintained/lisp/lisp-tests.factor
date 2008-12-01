! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test sequences math kernel parser arrays lists
quotations ;

IN: lisp.test

[
    define-lisp-builtins
    
    { 5 } [
        "(+ 2 3)" lisp-eval
    ] unit-test
    
    { 8.3 } [
        "(- 10.4 2.1)" lisp-eval
    ] unit-test
    
    { 3 } [
        "((lambda (x y) (+ x y)) 1 2)" lisp-eval
    ] unit-test
    
    { 42 } [
        "((lambda (x y z) (+ x (- y z))) 40 3 1)" lisp-eval
    ] unit-test
    
    { "b" } [
        "(cond (#f \"a\") (#t \"b\"))" lisp-eval
    ] unit-test
    
    { "b" } [
        "(cond ((< 1 2) \"b\") (#t \"a\"))" lisp-eval
    ] unit-test
        
    { +nil+ } [
        "(list)" lisp-eval
    ] unit-test
    
    { { 1 2 3 4 5 } } [
        "(list 1 2 3 4 5)" lisp-eval list>seq
    ] unit-test
    
    { { 1 2 { 3 { 4 } 5 } } } [
        "(list 1 2 (list 3 (list 4) 5))" lisp-eval cons>seq
    ] unit-test
    
    { 5 } [
        "(begin (+ 1 4))" lisp-eval
    ] unit-test
    
    { 5 } [
        "(begin (+ 5 6) (+ 1 4))" lisp-eval
    ] unit-test
    
    { t } [
        T{ lisp-symbol f "if" } lisp-macro?
    ] unit-test
    
    { 1 } [
        "(if #t 1 2)" lisp-eval
    ] unit-test
    
    { 3 } [
        "((lambda (x) (if x (+ 1 2) (- 3 5))) #t)" lisp-eval
    ] unit-test
    
    { { 5 4 3 } } [
        "((lambda (x &rest xs) (cons x xs)) 5 4 3)" lisp-eval cons>seq
    ] unit-test
    
    { { 5 } } [
        "((lambda (x &rest xs) (cons x xs)) 5)" lisp-eval cons>seq
    ] unit-test
    
    { { 1 2 3 4 } } [
        "((lambda (&rest xs) xs) 1 2 3 4)" lisp-eval cons>seq
    ] unit-test
    
    { 10 } [
        <LISP (begin (+ 1 2) (+ 9 1)) LISP>
    ] unit-test
    
    { 4 } [
        <LISP ((lambda (x y) (if x (+ 1 y) (+ 2 y))) #t 3) LISP>
    ] unit-test
    
    { { 3 3 4 } } [
        <LISP (defun foo (x y &rest z)
                  (cons (+ x y) z))
              (foo 1 2 3 4)
        LISP> cons>seq
    ] unit-test
    
] with-interactive-vocabs
