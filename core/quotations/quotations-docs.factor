USING: help.markup help.syntax kernel sequences ;
IN: quotations

ARTICLE: "quotations" "Quotations"
"A quotation is an anonymous function (a value denoting a snippet of code) which can be used as a value and called using the " { $link "call" } "."
$nl
"Quotation literals appearing in source code are delimited by square brackets, for example " { $snippet "[ 2 + ]" } "; see " { $link "syntax-quots" } " for details on their syntax."
$nl
"Quotations form a class of objects:"
{ $subsections
    quotation
    quotation?
}
"A more general class is provided for methods to dispatch on that includes quotations, " { $link curry } ", and " { $link compose } " objects:"
{ $subsections
    callable
}
"Quotations evaluate sequentially from beginning to end. Literals are pushed on the stack and words are executed. Details can be found in " { $link "evaluator" } ". Words can be placed in wrappers to suppress execution:"
{ $subsections "wrappers" }
"Quotations implement the " { $link "sequence-protocol" } ", and existing sequences can be converted into quotations:"
{ $subsections
    >quotation
    1quotation
}
"Although quotations can be treated as sequences, the compiler will be unable to reason about quotations manipulated as sequences at runtime. " { $link "compositional-combinators" } " are provided for runtime partial application and composition of quotations." ;

ARTICLE: "wrappers" "Wrappers"
"Wrappers evaluate to the object being wrapped when encountered in code. They are used to suppress the execution of " { $link "words" } " so that they can be used as values."
{ $subsections
    wrapper
    literalize
}
"Wrapper literal syntax is documented in " { $link "syntax-words" } "."
{ $example
  "IN: scratchpad"
  "DEFER: my-word"
  "\\ my-word name>> ."
  "\"my-word\""
}
{ $see-also "combinators" } ;

ABOUT: "quotations"

HELP: callable
{ $class-description "The class whose instances can be passed to " { $link call } ". This includes quotations and composed quotations built up with " { $link curry } " or " { $link compose } "." } ;

HELP: quotation
{ $class-description "The class of quotations. See " { $link "syntax-quots" } " for syntax and " { $link "quotations" } " for general information." } ;

HELP: >quotation
{ $values { "seq" sequence } { "quot" quotation } }
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
{ $class-description "The class of wrappers. Wrappers are created by calling " { $link literalize } ". See " { $link "syntax-words" } " for syntax." } ;

HELP: <wrapper>
{ $values { "obj" object } { "wrapper" wrapper } }
{ $description "Creates an object which pushes " { $snippet "obj" } " on the stack when evaluated. User code should call " { $link literalize } " instead, since it avoids wrapping self-evaluating objects (which is redundant)." } ;

HELP: literalize
{ $values { "obj" object } { "wrapped" object } }
{ $description "Outputs an object which evaluates to " { $snippet "obj" } " when placed in a quotation. If " { $snippet "obj" } " is not self-evaluating (for example, it is a word), then it will be wrapped." }
{ $examples
    { $example "USING: prettyprint quotations ;" "5 literalize ." "5" }
    { $example "USING: math prettyprint quotations sequences ;" "[ + ] [ literalize ] map ." "[ \\ + ]" }
} ;

{ literalize curry <wrapper> POSTPONE: \ POSTPONE: W{ } related-words

HELP: compose-all
{ $values { "seq" sequence } { "quot" quotation } }
{ $description "Returns a quotation made from " { $link compose } " called on each element of the sequence." } ;
