USING: alien alien.libraries alien.syntax formatting io.pathnames
kernel system tools.test ;
IN: alien.libraries.tests

[ f ] [ DLL" fadfasdfsada" dll-valid? ] unit-test

[ f ] [ "does not exist" DLL" fadsfasfdsaf" dlsym ] unit-test

[ ] [ "doesnotexist" dlopen dlclose ] unit-test

[ "fdasfsf" dll-valid? drop ] must-fail

[ t ] [
    "test-library" "blah" cdecl add-library
    "test-library" "BLAH" cdecl add-library?
    "blah" remove-library
] unit-test

[ t ] [
    "test-library" "blah" cdecl add-library
    "test-library" "blah" stdcall add-library?
    "blah" remove-library
] unit-test

[ f ] [
    "test-library" "blah" cdecl add-library
    "test-library" "blah" cdecl add-library?
    "blah" remove-library
] unit-test

! dlopen resolves resource:-paths
os windows? [
    [ t ] [
        vm file-stem "resource:/%s.exe" sprintf dlopen dll-valid?
    ] unit-test
] when
