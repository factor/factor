USING: arrays.nested-syntax kernel tools.test ;
IN: arrays.nested-syntax.tests

[ { { 1 } { 2 3 } { 4 5 6 } } ]
[ {{ 1 ;; 2 3 ;; 4 5 6 }} ] unit-test

[ H{ { "foo" 1 } { "bar" 2 } { "bas" 3 } } ]
[ H{{ "foo" 1 ;; "bar" 2 ;; "bas" 3 }} ] unit-test

[ { [ drop ] [ nip ] } ]
[ [[ drop ;; nip ]] ] unit-test
