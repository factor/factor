IN: optimizer.specializers
USING: help.markup help.syntax sequences words quotations ;

ARTICLE: "specializers" "Word specializers"
"The optimizer can be passed hints as to the classes of parameters a word is expected to be called with. The optimizer will then generate multiple versions of word when compiling, specialized to each class."
$nl
"Specialization hints are stored in the " { $snippet "\"specializer\"" } " word property. The value of this property is either a sequence of classes, or a sequence of sequences of classes. Each element in the sequence (or the sequence itself, in the former case) is a specialization hint."
$nl
"Specialization can help in the case where a word calls a lot of generic words on the same object - perhaps in a loop - and in most cases, it is anticipated that this object is of a certain class. Using specialization hints, the compiler can be instructed to compile a branch at the beginning of the word; if the branch is taken, the input object has the assumed class, and inlining of generic methods can take place."
$nl
"Specialization hints are not declarations; if the inputs do not match what is specified, the word will still run, possibly slower if the compiled code cannot inline methods because of insufficient static type information."
$nl
"In some cases, specialization will not help at all, and can make generated code slower from the increase in code size. The compiler is capable of inferring enough static type information to generate efficient code in many cases without explicit help from the programmer. Specializers should be used as a last resort, after profiling shows that a critical loop makes a lot of repeated calls to generic words which dispatch on the same class."
$nl
"For example, the " { $link append } " word has a specializer for the very common case where two strings or two arrays are appended:"
{ $code
"\\ append"
"{ { string string } { array array } }"
"\"specializer\" set-word-prop"
}
"The specialized version of a word which will be compiled by the compiler can be inspected:"
{ $subsection specialized-def } ;

HELP: specialized-def
{ $values { "word" word } { "quot" quotation } }
{ $description "Outputs the definition of a word after it has been split into specialized branches. This is the definition which will actually be compiled by the compiler." } ;
