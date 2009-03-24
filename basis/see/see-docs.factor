IN: see
USING: help.markup help.syntax strings prettyprint.private
definitions generic words classes ;

HELP: synopsis
{ $values { "defspec" "a definition specifier" } { "str" string } }
{ $contract "Prettyprints the prologue of a definition." } ;

HELP: synopsis*
{ $values { "defspec" "a definition specifier" } }
{ $contract "Adds sections to the current block corresponding to a the prologue of a definition, in source code-like form." }
{ $notes "This word should only be called from inside the " { $link with-pprint } " combinator. Client code should call " { $link synopsis } " instead." } ;

HELP: see
{ $values { "defspec" "a definition specifier" } }
{ $contract "Prettyprints a definition." } ;

HELP: see-methods
{ $values { "word" "a " { $link generic } " or a " { $link class } } }
{ $contract "Prettyprints the methods defined on a generic word or class." } ;

HELP: definer
{ $values { "defspec" "a definition specifier" } { "start" word } { "end" "a word or " { $link f } } }
{ $contract "Outputs the parsing words which delimit the definition." }
{ $examples
    { $example "USING: definitions prettyprint ;"
               "IN: scratchpad"
               ": foo ( -- ) ; \\ foo definer . ."
               ";\nPOSTPONE: :"
    }
    { $example "USING: definitions prettyprint ;"
               "IN: scratchpad"
               "SYMBOL: foo \\ foo definer . ."
               "f\nPOSTPONE: SYMBOL:"
    }
}
{ $notes "This word is used in the implementation of " { $link see } "." } ;

HELP: definition
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence" } }
{ $contract "Outputs the body of a definition." }
{ $examples
    { $example "USING: definitions math prettyprint ;" "\\ sq definition ." "[ dup * ]" }
}
{ $notes "This word is used in the implementation of " { $link see } "." } ;

ARTICLE: "see" "Printing definitions"
"The " { $vocab-link "see" } " vocabulary implements support for printing out " { $link "definitions" } " in the image."
$nl
"Printing a definition:"
{ $subsection see }
"Printing the methods defined on a generic word or class (see " { $link "objects" } "):"
{ $subsection see-methods }
"Definition specifiers implementing the " { $link "definition-protocol" } " should also implement the " { $emphasis "see protocol" } ":"
{ $subsection see* }
{ $subsection synopsis* } ;

ABOUT: "see"