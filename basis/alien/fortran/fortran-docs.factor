! Copyright (C) 2009 Joe Groff
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences strings ;
QUALIFIED-WITH: alien.syntax c
IN: alien.fortran

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
    { "Fortran records defined by " { $link POSTPONE: RECORD: } " and C structs defined by " { $link POSTPONE: c:C-STRUCT: } " are also supported as parameters." }
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
{ $description "Sets the logical library for subsequent " { $link POSTPONE: FUNCTION: } " and " { $link POSTPONE: SUBROUTINE: } " definitions." } ;

HELP: RECORD:
{ $syntax "RECORD: NAME { \"TYPE\" \"SLOT\" } ... ;" }
{ $description "Defines a Fortran record type with the given slots." } ;

HELP: fortran-invoke
{ $values
     { "return" string } { "library" string } { "procedure" string } { "parameters" sequence }
}
{ $description "Invokes the Fortran subroutine or function " { $snippet "procedure" } " in " { $snippet "library" } " with parameters specified by the " { $link "alien.fortran-types" } " specified in the " { $snippet "parameters" } " sequence. If the " { $snippet "return" } " value is " { $link f } ", no return value is expected, otherwise a return value of the specified Fortran type is expected. Input values are taken off the top of the datastack, and output values are left for the return value (if any) and any parameters specified as out parameters by prepending " { $snippet "\"!\"" } "." }
;

ARTICLE: "alien.fortran" "Fortran FFI"
"The " { $vocab-link "alien.fortran" } " vocabulary provides an interface to code shared libraries written in Fortran."
{ $subsection "alien.fortran-types" }
{ $subsection POSTPONE: LIBRARY: }
{ $subsection POSTPONE: FUNCTION: }
{ $subsection POSTPONE: SUBROUTINE: }
{ $subsection POSTPONE: RECORD: }
{ $subsection fortran-invoke }
;

ABOUT: "alien.fortran"
