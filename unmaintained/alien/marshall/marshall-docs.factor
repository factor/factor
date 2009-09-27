! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences
strings alien alien.c-types alien.data math byte-arrays ;
IN: alien.marshall

<PRIVATE
: $memory-note ( arg -- )
    drop "This word returns a pointer to unmanaged memory."
    print-element ;

: $c-ptr-note ( arg -- )
    drop "Does nothing if its argument is a non false c-ptr."
    print-element ;

: $see-article ( arg -- )
    drop { "See " { $vocab-link "alien.inline" } "." }
    print-element ;
PRIVATE>

HELP: ?malloc-byte-array
{ $values
    { "c-type" c-type }
    { "alien" alien }
}
{ $description "Does nothing if input is an alien, otherwise assumes it is a byte array and calls "
  { $snippet "malloc-byte-array" } "."
}
{ $notes $memory-note } ;

HELP: alien-wrapper
{ $var-description "For wrapping C pointers in a structure factor can dispatch on." } ;

HELP: unmarshall-cast
{ $values
    { "alien-wrapper" alien-wrapper }
    { "alien-wrapper'" alien-wrapper }
}
{ $description "Called immediately after unmarshalling. Useful for automatically casting to subtypes." } ;

HELP: marshall-bool
{ $values
    { "?" "a generalized boolean" }
    { "n" "0 or 1" }
}
{ $description "Marshalls objects to bool." }
{ $notes "Will treat " { $snippet "0" } " as " { $snippet "t" } "." } ;

HELP: marshall-bool*
{ $values
    { "?/seq" "t/f or sequence" }
    { "alien" alien }
}
{ $description "When the argument is a sequence, returns a pointer to an array of bool, "
   "otherwise returns a pointer to a single bool value."
}
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-bool**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description "Takes a one or two dimensional array of generalized booleans "
  "and returns a pointer to the equivalent C structure."
}
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-primitive
{ $values
    { "n" number }
    { "n" number }
}
{ $description "Marshall numbers to C primitives."
    $nl
    "Factor marshalls numbers to primitives for FFI calls, so all "
    "this word does is convert " { $snippet "t" } " to " { $snippet "1" }
    ", " { $snippet "f" } " to " { $snippet "0" } ", and lets anything else "
    "pass through untouched."
} ;

HELP: marshall-char*
{ $values
    { "n/seq" "number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-char**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-char**-or-strings
{ $values
    { "seq" "a sequence of strings" }
    { "alien" alien }
}
{ $description "Marshalls an array of strings or characters to an array of C strings." }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-char*-or-string
{ $values
    { "n/string" "a number or string" }
    { "alien" alien }
}
{ $description "Marshalls a string to a C string or a number to a pointer to " { $snippet "char" } "." }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-double*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-double**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-float*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-float**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-int*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-int**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-long*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-long**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-longlong*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-longlong**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-non-pointer
{ $values
    { "alien-wrapper/byte-array" "an alien-wrapper or byte-array" }
    { "byte-array" byte-array }
}
{ $description "Converts argument to a byte array." }
{ $notes "Not meant to be called directly. Use the output of " { $link marshaller } " instead." } ;

HELP: marshall-pointer
{ $values
    { "obj" object }
    { "alien" alien }
}
{ $description "Converts argument to a C pointer." }
{ $notes "Can marshall the following types: " { $snippet "alien, f, byte-array, alien-wrapper, struct-array" } "." } ;

HELP: marshall-short*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-short**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-uchar*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-uchar**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-uint*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-uint**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ulong*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ulong**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ulonglong*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ulonglong**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ushort*
{ $values
    { "n/seq" "a number or sequence" }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-ushort**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description $see-article }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshall-void**
{ $values
    { "seq" sequence }
    { "alien" alien }
}
{ $description "Marshalls a sequence of objects to an array of pointers to void." }
{ $notes { $list $c-ptr-note $memory-note } } ;

HELP: marshaller
{ $values
    { "type" "a C type string" }
    { "quot" quotation }
}
{ $description "Given a C type, returns a quotation that will marshall its argument to that type." } ;

HELP: out-arg-unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot" quotation }
}
{ $description "Like " { $link unmarshaller } " but returns an empty quotation "
    "for all types except pointers to non-const primitives."
} ;

HELP: class-unmarshaller
{ $values
    { "type" " a C type string" }
    { "quot/f" quotation }
}
{ $description "If in the vocab in which this word is called, there is a subclass of " { $link alien-wrapper }
    " named after the type argument, " { $snippet "pointer-unmarshaller" } " will return a quotation which "
    "wraps its argument in an instance of that subclass. In any other case it returns an empty quotation."
}
{ $notes "Not meant to be called directly. Use the output of " { $link marshaller } " instead." } ;

HELP: primitive-marshaller
{ $values
    { "type" "a C type string" }
    { "quot/f" "a quotation or f" }
}
{ $description "Returns a quotation to marshall objects to the argument type." }
{ $notes "Not meant to be called directly. Use the output of " { $link marshaller } " instead." } ;

HELP: primitive-unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot/f" "a quotation or f" }
}
{ $description "Returns a quotation to unmarshall objects from the argument type." }
{ $notes "Not meant to be called directly. Use the output of " { $link unmarshaller } " instead." } ;

HELP: struct-field-unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot" quotation }
}
{ $description "Like " { $link unmarshaller } " but returns a quotation that "
    "does not call " { $snippet "free" } " on its argument."
}
{ $notes "Not meant to be called directly. Use the output of " { $link unmarshaller } " instead." } ;

HELP: struct-primitive-unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot/f" "a quotation or f" }
}
{ $description "Like " { $link primitive-unmarshaller } " but returns a quotation that "
    "does not call " { $snippet "free" } " on its argument." }
{ $notes "Not meant to be called directly. Use the output of " { $link unmarshaller } " instead." } ;

HELP: struct-unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot/f" quotation }
}
{ $description "Returns a quotation which wraps its argument in the subclass of "
    { $link struct-wrapper } " which matches the " { $snippet "type" } " arg."
}
{ $notes "Not meant to be called directly. Use the output of " { $link unmarshaller } " instead." } ;

HELP: struct-wrapper
{ $var-description "For wrapping C structs in a structure factor can dispatch on." } ;

HELP: unmarshall-bool
{ $values
    { "n" number }
    { "?" "a boolean" }
}
{ $description "Unmarshalls a number to a boolean." } ;

HELP: unmarshall-bool*
{ $values
    { "alien" alien }
    { "?" "a boolean" }
}
{ $description "Unmarshalls a C pointer to a boolean." } ;

HELP: unmarshall-bool*-free
{ $values
    { "alien" alien }
    { "?" "a boolean" }
}
{ $description "Unmarshalls a C pointer to a boolean and frees the pointer." } ;

HELP: unmarshall-char*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-char*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-char*-to-string
{ $values
    { "alien" alien }
    { "string" string }
}
{ $description "Unmarshalls a " { $snippet "char" } " pointer to a factor string." } ;

HELP: unmarshall-char*-to-string-free
{ $values
    { "alien" alien }
    { "string" string }
}
{ $description "Unmarshalls a " { $snippet "char" } " pointer to a factor string and frees the pointer." } ;

HELP: unmarshall-double*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-double*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-float*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-float*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-int*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-int*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-long*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-long*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-longlong*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-longlong*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-short*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-short*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-uchar*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-uchar*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-uint*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-uint*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ulong*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ulong*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ulonglong*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ulonglong*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ushort*
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshall-ushort*-free
{ $values
    { "alien" alien }
    { "n" number }
}
{ $description $see-article } ;

HELP: unmarshaller
{ $values
    { "type" "a C type string" }
    { "quot" quotation }
}
{ $description "Given a C type, returns a quotation that will unmarshall values of that type." } ;

ARTICLE: "alien.marshall" "C marshalling"
{ $vocab-link "alien.marshall" } " provides alien wrappers and marshalling words for the "
"automatic marshalling and unmarshalling of C function arguments, return values, and output parameters."

{ $subheading "Important words" }
"Wrap an alien:" { $subsection alien-wrapper }
"Wrap a struct:" { $subsection struct-wrapper }
"Get the marshaller for a C type:" { $subsection marshaller }
"Get the unmarshaller for a C type:" { $subsection unmarshaller }
"Get the unmarshaller for an output parameter:" { $subsection out-arg-unmarshaller }
"Get the unmarshaller for a struct field:" { $subsection struct-field-unmarshaller }
$nl
"Other marshalling and unmarshalling words in this vocabulary are not intended to be "
"invoked directly."
$nl
"Most marshalling words allow non false c-ptrs to pass through unchanged."

{ $subheading "Primitive marshallers" }
{ $subsection marshall-primitive } "for marshalling primitive values."
{ $subsection marshall-int* }
  "marshalls a number or sequence of numbers. If argument is a sequence, returns a pointer "
  "to a C array, otherwise returns a pointer to a single value."
{ $subsection marshall-int** }
"marshalls a 1D or 2D array of numbers. Returns an array of pointers to arrays."

{ $subheading "Primitive unmarshallers" }
{ $snippet "unmarshall-<prim>*" } " and " { $snippet "unmarshall-<prim>*-free" }
" for all values of " { $snippet "<prim>" } " in " { $link primitive-types } "."
{ $subsection unmarshall-int* }
"unmarshalls a pointer to primitive. Returns a number. "
"Assumes the pointer is not an array (if it is, only the first value is returned). "
"C functions that return arrays are not handled correctly by " { $snippet "alien.marshall" }
" and must be unmarshalled by hand."
{ $subsection unmarshall-int*-free }
"unmarshalls a pointer to primitive, and then frees the pointer."
$nl
"Primitive values require no unmarshalling. The factor FFI already does this."
;

ABOUT: "alien.marshall"
