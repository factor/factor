! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math strings ;
IN: ryu

ABOUT: "ryu"

ARTICLE: "ryu" "Ryū Float to String Conversion"
{ "The " { $vocab-link "ryu" } " vocab contains a Factor implementation of the Ryū algorithm to quickly convert floating point numbers to decimal strings. Only the double-precision floats (64-bit) are supported. Original author's reference implementation (C and Java) and additional information can be found here: " { $url "https://github.com/ulfjack/ryu" } "."
{ $subsections print-float d2s } } ;

HELP: print-float
{ $values
    { "value" number }
    { "string" string }
}
{ $description "Convert the " { $snippet "number" } " into its shortest stable floating-point representation string using the Ryū algorithm." } ;

HELP: d2s
{ $values
    { "value" number }
    { "string" string }
}
{ $description "An alias for " { $link print-float } "." } ;
