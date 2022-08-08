USING: assocs help.markup help.syntax quotations strings words ;
IN: bootstrap.image.primitives

HELP: all-primitives
{ $description "A constant " { $link assoc } " containing all primitives. Keys are vocab names and values are sequences of tuples declaring words. The format of the tuples are { name effect vm-func inputs outputs extra-props }:"
  { $list
    { "name: Name of the primitive." }
    { "effect: The primitives stack effect." }
    { "vm-func: If it is a " { $link string } " then the primitive will call a function implemented in C++ code. If 'vm-func' is " { $link f } " then it is a sub-primitive and implemented in one of the files in 'basis/bootstrap/assembler/'." }
    { "inputs: The primitives \"input-classes\", if any." }
    { "outputs: The primitives \"output-classes\", if any." }
    { "extra-word: An " { $link word } " that is run with the created word as argument to add extra properties to it. Usually, it would be " { $link make-foldable } " or " { $link make-flushable } " to make the word foldable or flushable respectively." }
  }
}
"See " { $link "word-props" } " for documentation of what all word properties do." ;

HELP: primitive-quot
{ $values { "word" word } { "vm-func" $maybe { string } } { "quot" quotation } }
{ $description "Creates the defining quotation for the primitive. If 'vm-func' is a string, then it is prefixed with 'primitive_' and a quotation calling that C++ function is generated." } ;

ARTICLE: "bootstrap.image.primitives" "Bootstrap primitives"
"This vocab contains utilities for declaring primitives to be added to the bootstrap image. It is used by the file " { $snippet "resource:basis/bootstrap/primitives.factor" }
$nl
{ $link all-primitives } " is an assoc where all primitives are declared. See that constant for a description of the format." ;

ABOUT: "bootstrap.image.primitives"
