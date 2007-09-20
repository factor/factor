USING: help.markup help.syntax words parser ;
IN: tools.annotations

ARTICLE: "tools.annotations" "Word annotations"
"The word annotation feature modifies word definitions to add debugging code. You can restore the old definition by calling " { $link reload } " on the word in question."
{ $subsection watch }
{ $subsection breakpoint }
{ $subsection breakpoint-if }
"All of the above words are implemented using a single combinator which applies a quotation to a word definition to yield a new definition:"
{ $subsection annotate } ;

ABOUT: "tools.annotations"

HELP: annotate
{ $values { "word" "a word" } { "quot" "a quotation with stack effect " { $snippet "( word def -- def )" } } }
{ $description "Changes a word definition to the result of applying a quotation to the old definition." }
{ $notes "This word is used to implement " { $link watch } "." } ;

HELP: watch
{ $values { "word" word } }
{ $description "Annotates a word definition to print the data stack on entry and exit." } ;

HELP: breakpoint
{ $values { "word" word } }
{ $description "Annotates a word definition to enter the single stepper when executed." } ;

HELP: breakpoint-if
{ $values { "quot" "a quotation with stack effect" { $snippet "( -- ? )" } } { "word" word } }
{ $description "Annotates a word definition to enter the single stepper if the quotation yields true." } ;
