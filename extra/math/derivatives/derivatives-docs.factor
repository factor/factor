! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: math.derivatives

ARTICLE: "math.derivatives" "Derivatives"
"The " { $vocab-link "math.derivatives" } " vocabulary defines the derivative of many of the words in the " { $vocab-link "math" } " and " { $vocab-link "math.functions" } " vocabularies. The derivative for a word is given by a sequence of quotations stored in its " { $snippet "derivative" } " word property that give the partial derivative of the word with respect to each of its inputs."
{ $see-also "math.derivatives.syntax" }
;

ABOUT: "math.derivatives"
