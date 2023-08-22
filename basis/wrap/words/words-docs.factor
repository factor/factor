! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup math kernel ;
IN: wrap.words

ABOUT: "wrap.words"

ARTICLE: "wrap.words" "Word object wrapping"
"The " { $vocab-link "wrap.words" } " vocabulary implements word wrapping on abstract word objects, which have certain properties making it a more suitable input representation than strings."
{ $subsections
    wrap-words
    wrapping-word
    <wrapping-word>
} ;

HELP: wrap-words
{ $values { "words" { "a sequence of " { $instance wrapping-word } "s" } } { "width" integer } { "lines" "a sequence of sequences of words" } }
{ $description "Divides the words into lines, where the sum of the lengths of the words on a line (not counting breaks at the end of the line) is at most the given maximum. The returned set of lines is optimized to minimize the square of the deviation of each line from the ideal width. It is not guaranteed to be the minimal number of lines. Every line except for the first one starts with a non-break, and every one but the last ends with a break." } ;

HELP: wrapping-word
{ $class-description "A word is a Factor object annotated with a length (in the " { $snippet "width" } " slot) and knowledge about whether it is an allowable position for an optional line break (in the " { $snippet "break?" } " slot). Words can be created with " { $link <wrapping-word> } "." }
{ $see-also wrap-words } ;

HELP: <wrapping-word>
{ $values { "key" object } { "width" integer } { "break?" { { $link t } " or " { $link POSTPONE: f } } } { "wrapping-word" wrapping-word } }
{ $description "Creates a " { $link wrapping-word } " object with the given parameters." }
{ $see-also wrap-words } ;
