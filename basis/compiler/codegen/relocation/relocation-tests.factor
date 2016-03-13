USING: accessors alien.strings alien.syntax
compiler.codegen.relocation namespaces sequences tools.test ;
IN: compiler.codegen.relocation.tests

{
    B{ 114 101 97 100 108 105 110 101 0 }
    "libreadline.so"
} [
    init-relocation
    "readline" DLL" libreadline.so" add-dlsym-parameters
    parameter-table get first2 path>> alien>native-string
] unit-test
