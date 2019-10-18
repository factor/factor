USING: help.markup help.syntax words.alias ;
IN: words.alias

ARTICLE: "words.alias" "Word aliasing"
"There is a syntax for defining new names for existing words. This useful for C library bindings, for example in the Win32 API, where words need to be renamed for symmetry."
$nl
"Define a new word that aliases another word:"
{ $subsections POSTPONE: ALIAS: }
"Define an alias at run-time:"
{ $subsections define-alias } ;

ABOUT: "words.alias"
