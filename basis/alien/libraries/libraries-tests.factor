IN: alien.libraries.tests
USING: alien.libraries alien.syntax tools.test kernel ;

[ f ] [ DLL" fadfasdfsada" dll-valid? ] unit-test

[ f ] [ "does not exist" DLL" fadsfasfdsaf" dlsym ] unit-test

[ ] [ "doesnotexist" dlopen dlclose ] unit-test

[ "fdasfsf" dll-valid? drop ] must-fail