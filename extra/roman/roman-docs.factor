USING: help.markup help.syntax kernel math ;
IN: roman

HELP: >roman
{ $values { "n" "an integer" } { "str" "a string" } }
{ $description "Converts a number to its lower-case Roman Numeral equivalent." }
{ $notes "The range for this word is 1-3999, inclusive." }
{ $see-also >ROMAN roman> } ;

HELP: >ROMAN
{ $values { "n" "an integer" } { "str" "a string" } }
{ $description "Converts a number to its upper-case Roman numeral equivalent." }
{ $notes "The range for this word is 1-3999, inclusive." }
{ $see-also >roman roman> } ;

HELP: roman>
{ $values { "str" "a string" } { "n" "an integer" } }
{ $description "Converts a Roman numeral to an integer." }
{ $notes "The range for this word is i-mmmcmxcix, inclusive." }
{ $see-also >roman } ;

HELP: roman+
{ $values { "str1" "a string" } { "str2" "a string" } { "str3" "a string" } }
{ $description "Adds two Roman numerals." }
{ $see-also roman- } ;

HELP: roman-
{ $values { "str1" "a string" } { "str2" "a string" } { "str3" "a string" } }
{ $description "Subtracts two Roman numerals." }
{ $see-also roman+ } ;

HELP: roman*
{ $values { "str1" "a string" } { "str2" "a string" } { "str3" "a string" } }
{ $description "Multiplies two Roman numerals." }
{ $see-also roman/i roman/mod } ;

HELP: roman/i
{ $values { "str1" "a string" } { "str2" "a string" } { "str3" "a string" } }
{ $description "Computes the integer division of two Roman numerals." }
{ $see-also roman* roman/mod /i } ;

HELP: roman/mod
{ $values { "str1" "a string" } { "str2" "a string" } { "str3" "a string" } { "str4" "a string" } }
{ $description "Computes the quotient and remainder of two Roman numerals." }
{ $see-also roman* roman/i /mod } ;
