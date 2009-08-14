USING: alien.libraries alien.syntax tools.test kernel ;
IN: alien.libraries.tests

[ f ] [ DLL" fadfasdfsada" dll-valid? ] unit-test

[ f ] [ "does not exist" DLL" fadsfasfdsaf" dlsym ] unit-test

[ ] [ "doesnotexist" dlopen dlclose ] unit-test

[ "fdasfsf" dll-valid? drop ] must-fail
