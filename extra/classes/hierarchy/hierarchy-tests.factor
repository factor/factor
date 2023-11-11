! Copyright (C) 2023 Jean-Marc Lugrin.
! See https://factorcode.org/license.txt for BSD license.

USING: tools.test classes.hierarchy assocs io.streams.string ;
IN: classes.hierarchy.tests

TUPLE: troot a b c ;

TUPLE: tchild1 < troot aa ;

TUPLE: tchild2 < troot  bb ;

{ { tchild1 tchild2 } }  [ troot class-hierarchy at ] unit-test 

[ f hierarchy. ] must-fail

{ "t < word\n" } [  [ t hierarchy. ] with-string-writer ] unit-test
{ "tchild1 < troot < tuple\n" } [  [ tchild1 hierarchy. ] with-string-writer ] unit-test
{ "troot < tuple\n| tchild1                                  IN: classes.hierarchy.tests\n| tchild2                                  IN: classes.hierarchy.tests\n" } 
    [  [ troot hierarchy. ] with-string-writer ] unit-test