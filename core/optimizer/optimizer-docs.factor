USING: help.markup help.syntax quotations words math
sequences ;
IN: optimizer

ARTICLE: "specializers" "Word specializers"
"The optimizer can be passed hints as to the classes of parameters a word is expected to be called with. The optimizer will then generate multiple versions of word when compiling, specialized to each class."
$nl
"Specialization hints are stored in the " { $snippet "\"specializer\"" } " word property. The value of this property is a sequence having the same number of elements as the word has inputs; each element takes one of the following forms and gives the compiler a hint about the corresponding parameter:"
{ $table
    { { $snippet { $emphasis "class" } } { "a class word indicates that this parameter is expected to be an instance of the class most of the time." } }
    { { $snippet "{ " { $emphasis "classes..." } " }" } { "a sequence of class words indicates that this parameter is expected to be an instance of one of these classes most of the time." } }
    { { $snippet "number" } { "the " { $link number } " class word has a special behavior. It will result in a version of the word being generated for every primitive numeric type, where this parameter is assumed to have that type. A fast jump table will then determine which version is chosen at run time." } }
    { { $snippet "*" } { "indicates no specialization should be performed on this parameter." } }
}
"Specialization can help in the case where a word calls a lot of generic words on the same object - perhaps in a loop - and in most cases, it is anticipated that this object is of a certain class. Using specialization hints, the compiler can be instructed to compile a branch at the beginning of the word; if the branch is taken, the input object has the assumed class, and inlining of generic methods can take place."
$nl
"Specialization hints are not declarations; if the inputs do not match what is specified, the word will still run, possibly slower if the compiled code cannot inline methods because of insufficient static type information."
$nl
"In some cases, specialization will not help at all, and can make generated code slower from the increase in code size. The compiler is capable of inferring enough static type information to generate efficient code in many cases without explicit help from the programmer. Specializers should be used as a last resort, after profiling shows that a critical loop makes a lot of repeated calls to generic words which dispatch on the same class."
$nl
"For example, the " { $link append } " word has a specializer for the very common case where two strings or two arrays are appended:"
{ $code
"\\ append"
"{ { string array } { string array } }"
"\"specializer\" set-word-prop"
}
"The specialized version of a word which will be compiled by the compiler can be inspected:"
{ $subsection specialized-def } ;

ARTICLE: "optimizer" "Optimizer"
"The words in the " { $vocab-link "optimizer" } " vocabulary are internal to the compiler and user code has no reason to call them."
$nl
"The main entry point into the optimizer:"
{ $subsection optimize }
{ $subsection "specializers" } ;

ABOUT: "optimizer"

HELP: optimize-1
{ $values { "node" "a dataflow graph" } { "newnode" "a dataflow graph" } { "?" "a boolean" } }
{ $description "Performs a single round of optimization on the dataflow graph, and outputs the new graph together with a new flag indicating if any changes were made." } ;

HELP: optimize
{ $values { "node" "a dataflow graph" } { "newnode" "a dataflow graph" } }
{ $description "Continues to optimize a dataflow graph until a fixed point is reached." } ;

HELP: specialized-def
{ $values { "word" word } { "quot" quotation } }
{ $description "Outputs the definition of a word after it has been split into specialized branches. This is the definition which will actually be compiled by the compiler." } ;
