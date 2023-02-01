USING: assocs graphs hash-sets kernel math namespaces sequences sorting
tools.test vectors ;
QUALIFIED: sets

H{ } "g" set
{ 1 2 3 } "v" set

{ } [ "v" dup get "g" get add-vertex ] unit-test

{ { "v" } } [ 1 "g" get at sets:members ] unit-test

H{
    { 1 HS{ 1 2 } }
    { 2 HS{ 3 4 } }
    { 4 HS{ 4 5 } }
} "g" set

{ { 2 3 4 5 } } [
    2 [ "g" get at sets:members ] closure sets:members sort
] unit-test

{ t } [ 2 [ "g" get at sets:members ] HS{ } closure-as hash-set? ] unit-test
{ t } [ 2 [ "g" get at sets:members ] closure hash-set? ] unit-test
{ t } [ 2 [ "g" get at sets:members ] V{ } closure-as vector? ] unit-test

{ V{ 5 4 3 2 1 0 } } [
    5 [ [ f ] [ <iota> <reversed> ] if-zero ] V{ } closure-as
] unit-test
