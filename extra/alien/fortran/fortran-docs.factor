! Copyright (C) 2009 Joe Groff
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences strings words.symbol classes.struct ;
QUALIFIED-WITH: alien.syntax c
IN: alien.fortran

ARTICLE: "alien.fortran-abis" "Fortran ABIs"
"Fortran does not have a standard ABI like C does. Factor supports the following Fortran ABIs:"
{ $list
    { { $link gfortran-abi } " is used by gfortran, the Fortran compiler included with GCC 4." }
    { { $link f2c-abi } " is used by the F2C Fortran-to-C translator and G77, the Fortran compiler included with GCC 3.x and earlier. It is also used by gfortran when compiling with the -ff2c flag." }
    { { $link intel-unix-abi } " is used by the Intel Fortran Compiler on Linux and Mac OS X." }
    { { $link intel-windows-abi } " is used by the Intel Fortran Compiler on Windows." }
}
"A library's ABI is specified when that library is opened by the " { $link add-fortran-library } " word." ;

ARTICLE: "alien.fortran-types" "Fortran types"
"The Fortran FFI recognizes the following Fortran types:"
{ $list
    { { $snippet "INTEGER" } " specifies a four-byte integer value. Sized integers can be specified with " { $snippet "INTEGER*1" } ", " { $snippet "INTEGER*2" } ", " { $snippet "INTEGER*4" } ", and " { $snippet "INTEGER*8" } "." }
    { { $snippet "LOGICAL" } " specifies a four-byte boolean value. Sized booleans can be specified with " { $snippet "LOGICAL*1" } ", " { $snippet "LOGICAL*2" } ", " { $snippet "LOGICAL*4" } ", and " { $snippet "LOGICAL*8" } "." }
    { { $snippet "REAL" } " specifies a single-precision floating-point real value." }
    { { $snippet "DOUBLE-PRECISION" } " specifies a double-precision floating-point real value. The alias " { $snippet "REAL*8" } " is also recognized." }
    { { $snippet "COMPLEX" } " specifies a single-precision floating-point complex value." }
    { { $snippet "DOUBLE-COMPLEX" } " specifies a double-precision floating-point complex value. The alias " { $snippet "COMPLEX*16" } " is also recognized." }
    { { $snippet "CHARACTER(n)" } " specifies a character string of length " { $snippet "n" } ". The Fortran 77 syntax " { $snippet "CHARACTER*n" } " is also recognized." }
    { "Fortran arrays can be specified by suffixing a comma-separated set of dimensions in parentheses, e.g. " { $snippet "REAL(2,3,4)" } ". Arrays of unspecified length can be specified using " { $snippet "*" } " as a dimension. Arrays are passed in as flat " { $link "specialized-arrays" } "." }
    { "Struct classes defined by " { $link POSTPONE: STRUCT: } " are also supported as parameter and return types." }
}
"When declaring the parameters of Fortran functions, an output argument can be specified by prefixing an exclamation point to the type name. This will cause the function word to leave the final value of the parameter on the stack." ;

HELP: FUNCTION:
{ $syntax "FUNCTION: RETURN-TYPE NAME ( [!]ARGUMENT-TYPE NAME, ... ) ;" }
{ $description "Declares a Fortran function binding with the given return type and arguments. See " { $link "alien.fortran-types" } " for a list of supported types." } ;

HELP: SUBROUTINE:
{ $syntax "SUBROUTINE: NAME ( [!]ARGUMENT-TYPE NAME, ... ) ;" }
{ $description "Declares a Fortran subroutine binding with the given arguments. See " { $link "alien.fortran-types" } " for a list of supported types." } ;

HELP: LIBRARY:
{ $syntax "LIBRARY: name" }
{ $values { "name" "a logical library name" } }
{ $description "Sets the logical library for subsequent " { $link POSTPONE: FUNCTION: } " and " { $link POSTPONE: SUBROUTINE: } " definitions. The given library name must have been opened with a previous call to " { $link add-fortran-library } "." } ;

HELP: add-fortran-library
{ $values { "name" string } { "soname" string } { "fortran-abi" symbol } }
{ $description "Opens the shared library in the file specified by " { $snippet "soname" } " under the logical name " { $snippet "name" } " so that it may be used in subsequent " { $link POSTPONE: LIBRARY: } " and " { $link fortran-invoke } " calls. Functions and subroutines from the library will be defined using the specified " { $snippet "fortran-abi" } ", which must be one of the supported " { $link "alien.fortran-abis" } "." }
;

HELP: fortran-invoke
{ $values
    { "return" string } { "library" string } { "procedure" string } { "parameters" sequence }
}
{ $description "Invokes the Fortran subroutine or function " { $snippet "procedure" } " in " { $snippet "library" } " with parameters specified by the " { $link "alien.fortran-types" } " specified in the " { $snippet "parameters" } " sequence. If the " { $snippet "return" } " value is " { $link f } ", no return value is expected, otherwise a return value of the specified Fortran type is expected. Input values are taken off the top of the datastack, and output values are left for the return value (if any) and any parameters specified as out parameters by prepending " { $snippet "\"!\"" } "." }
;

ARTICLE: "alien.fortran" "Fortran FFI"
"The " { $vocab-link "alien.fortran" } " vocabulary provides an interface to code in shared libraries written in Fortran."
{ $subsections
    "alien.fortran-types"
    "alien.fortran-abis"
    add-fortran-library
    POSTPONE: LIBRARY:
    POSTPONE: FUNCTION:
    POSTPONE: SUBROUTINE:
    fortran-invoke
} ;

ABOUT: "alien.fortran"
