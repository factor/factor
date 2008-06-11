! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test sequences math kernel parser arrays lists
quotations ;

IN: lisp.test

[
    init-env
    
    [ f ] "#f" lisp-define
    [ t ] "#t" lisp-define
    
    "+" "math" "+" define-primitive
    "-" "math" "-" define-primitive
    
    "cons" "lists" "cons" define-primitive
    "car" "lists" "car" define-primitive
    "cdr" "lists" "cdr" define-primitive
    "append" "lists" "lappend" define-primitive
    "nil" "lists" "nil" define-primitive
    "nil?" "lists" "nil?" define-primitive
    
    [ seq>list ] "##list" lisp-define
    
    "define" "lisp" "defun" define-primitive
    
    "(lambda (&rest xs) xs)" lisp-string>factor "list" lisp-define
        
    { 5 } [
      ! [ 2 3 ] "+" <lisp-symbol> funcall
      "(+ 2 3)" lisp-eval
    ] unit-test
    
    { 8.3 } [
     ! [ 10.4 2.1 ] "-" <lisp-symbol> funcall
     "(- 10.4 2.1)" lisp-eval
    ] unit-test
    
    { 3 } [
      "((lambda (x y) (+ x y)) 1 2)" lisp-eval
    ] unit-test
    
!     { 42 } [
!       "((lambda (x y z) (+ x (- y z))) 40 3 1)" lisp-eval
!     ] unit-test
    
    { "b" } [
      "(cond (#f \"a\") (#t \"b\"))" lisp-eval
    ] unit-test
    
    { 5 } [
      "(begin (+ 1 4))" lisp-eval
    ] unit-test
    
    { { 1 2 3 4 5 } } [
        "(list 1 2 3 4 5)" lisp-eval list>seq
    ] unit-test
    
    { { 1 2 { 3 { 4 } 5 } } } [
        "(list 1 2 (list 3 (list 4) 5))" lisp-eval cons>seq
    ] unit-test
    
    { T{ lisp-symbol f "if" } } [
        "(defmacro if (pred tr fl) (list (quote cond) (list (list pred tr) (list t fl))))" lisp-eval
    ] unit-test
    
    { t } [
        T{ lisp-symbol f "if" } lisp-macro?
    ] unit-test
    
!     { 1 } [
!       "(if #t 1 2)" lisp-eval
!     ] unit-test
    
!     { 3 } [
!        "((lambda (x) (if x (begin (+ 1 2)) (- 3 5))) #t)" lisp-eval
!     ] unit-test
    
] with-interactive-vocabs
