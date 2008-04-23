[ [ T{ lisp-symbol f "foo" } [ 2 T{ lisp-symbol f "bar" } ] [ 3 4 T{ lisp-symbol f "baz" } ] if ] ]
  [ "(if foo (bar 2) (baz 3 4))" lisp-expr parse-result-ast convert-if ] unit-test
  
  