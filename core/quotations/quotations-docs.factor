USING: arrays help.markup help.syntax strings sbufs
vectors kernel combinators ;
IN: quotations

ARTICLE: "quotations" "Quotations"
"Conceptually, a quotation is a snippet of code which can be passed around and called. Concretely, a quotation is a sequence of objects, some of which may be words. When evaluating a quotation, the interpreter looks at each element in turn, and executes words while pushing other types of objects on the stack. Details can be found in " { $link "interpreter" } "."
$nl
"Quotation literal syntax is documented in " { $link "syntax-quots" } "."
$nl
"Quotations implement the " { $link "sequence-protocol" } ", and existing sequences can be converted into quotations:"
{ $subsection >quotation }
{ $subsection 1quotation }
"Wrappers are used to push words on the data stack; they evaluate to the object being wrapped:"
{ $subsection wrapper }
{ $subsection literalize }
{ $see-also "basic-combinators" "combinators" } ;

ABOUT: "quotations"

HELP: callable
{ $class-description "The class whose instances can be passed to " { $link call } ". This includes quotations, " { $link f } " (which behaves like an empty quotation), and composed quotations built up with " { $link curry } "." } ;

HELP: quotation
{ $description "The class of quotations. See " { $link "syntax-quots" } " for syntax and " { $link "quotations" } " for general information." } ;

HELP: <quotation>
{ $values { "n" "a non-negative integer" } { "quot" quotation } }
{ $description "Creates a new quotation with the given length and all elements initially set to " { $link f } "." } ;

HELP: >quotation
{ $values { "seq" "a sequence" } { "quot" quotation } }
{ $description "Outputs a freshly-allocated quotation with the same elements as a given sequence." } ;

HELP: 1quotation
{ $values { "obj" object } { "quot" quotation } }
{ $description "Constructs a quotation holding one element." }
{ $notes
    "The following two phrases are equivalent:"
    { $code "\\ reverse execute" }
    { $code "\\ reverse 1quotation call" }
} ;

HELP: wrapper
{ $description "The class of wrappers. Wrappers are created by calling " { $link literalize } ". See " { $link "syntax-words" } " for syntax." } ;

HELP: <wrapper> ( obj -- wrapper )
{ $values { "obj" object } { "wrapper" wrapper } }
{ $description "Creates an object which pushes " { $snippet "obj" } " on the stack when evaluated. User code should call " { $link literalize } " instead, since it avoids wrapping self-evaluating objects (which is redundant)." } ;

HELP: literalize
{ $values { "obj" object } { "wrapped" object } }
{ $description "Outputs an object which evaluates to " { $snippet "obj" } " when placed in a quotation. If " { $snippet "obj" } " is not self-evaluating (for example, it is a word), then it will be wrapped." }
{ $examples
    { $example "USE: quotations" "5 literalize ." "5" }
    { $example "USE: quotations" "[ + ] [ literalize ] map ." "[ \\ + ]" }
} ;

{ literalize curry <wrapper> POSTPONE: \ POSTPONE: W{ } related-words
