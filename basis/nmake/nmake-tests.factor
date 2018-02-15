USING: nmake kernel tools.test ;

{ } [ [ ] { } nmake ] unit-test

{ { 1 } { 2 } } [ [ 1 0, 2 1, ] { { } { } } nmake ] unit-test

[ [ ] [ call ] curry { { } } nmake ] must-infer
