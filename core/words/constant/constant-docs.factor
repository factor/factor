USING: help.markup help.syntax words.constant ;
IN: words.constant

ARTICLE: "words.constant" "Constants"
"There is a syntax for defining words which push literals on the stack."
$nl
"Define a new word that pushes a literal on the stack:"
{ $subsections POSTPONE: CONSTANT: }
"Define an constant at run-time:"
{ $subsections define-constant } ;

ABOUT: "words.constant"
