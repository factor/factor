IN: hints
USING: help.markup help.syntax words quotations sequences ;

ARTICLE: "hints" "Compiler specialization hints"
"Specialization hints help the compiler generate efficient code."
$nl
"Specialization hints can help words which call a lot of generic words on the same object - perhaps in a loop - and in most cases, it is anticipated that this object is of a certain class. Using specialization hints, the compiler can be instructed to compile a branch at the beginning of the word; if the branch is taken, the input object has the assumed class, and inlining of generic methods can take place."
$nl
"Specialization hints are not declarations; if the inputs do not match what is specified, the word will still run, possibly slower if the compiled code cannot inline methods because of insufficient static type information."
$nl
"In some cases, specialization will not help at all, and can make generated code slower from the increase in code size. The compiler is capable of inferring enough static type information to generate efficient code in many cases without explicit help from the programmer. Specializers should be used as a last resort, after profiling shows that a critical loop makes a lot of repeated calls to generic words which dispatch on the same class."
$nl
"Type hints are declared with a parsing word:"
{ $subsection POSTPONE: HINTS: }
"The specialized version of a word which will be compiled by the compiler can be inspected:"
{ $subsection specialized-def } ;

HELP: specialized-def
{ $values { "word" word } { "quot" quotation } }
{ $description "Outputs the definition of a word after it has been split into specialized branches. This is the definition which will actually be compiled by the compiler." } ;

HELP: HINTS:
{ $values { "defspec" "a definition specifier" } { "hints..." "a list of sequences of classes" } }
{ $description "Defines specialization hints for a word or a method."
$nl
"Each sequence of classes in the list will cause a specialized version of the word to be compiled." }
{ $examples "The " { $link append } " word has a specializer for the very common case where two strings or two arrays are appended:"
{ $code "HINTS: append { string string } { array array } ;" }
"Specializers can also be defined on methods:"
{ $code
    "GENERIC: count-occurrences ( elt obj -- n )"
    ""
    "M: sequence count-occurrences [ = ] with count ;"
    ""
    "M: assoc count-occurrences"
    "    swap [ = nip ] curry assoc-filter assoc-size ;"
    ""
    "HINTS: { sequence count-occurrences } { object array } ;"
    "HINTS: { assoc count-occurrences } { object hashtable } ;"
}
} ;

ABOUT: "hints"
