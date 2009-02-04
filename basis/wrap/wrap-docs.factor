! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings math kernel ;
IN: wrap

ABOUT: "wrap"

ARTICLE: "wrap" "Word wrapping"
"The " { $vocab-link "wrap" } " vocabulary implements word wrapping. There is support for simple string wrapping, with the following words:"
{ $subsection wrap-lines }
{ $subsection wrap-string }
{ $subsection wrap-indented-string }
"Additionally, the vocabulary provides capabilities to wrap arbitrary groups of things, in units called words."
{ $subsection wrap }
{ $subsection word }
{ $subsection <word> } ;

HELP: wrap-lines
{ $values { "lines" string } { "width" integer } { "newlines" "sequence of strings" } }
{ $description "Given a string, divides it into a sequence of lines where each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-string
{ $values { "string" string } { "width" integer } { "newstring" string } }
{ $description "Given a string, alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-indented-string
{ $values { "string" string } { "width" integer } { "indent" string } { "newstring" string } }
{ $description "Given a string, alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space. Before each line, the indent string is added." } ;

HELP: wrap
{ $values { "words" { "a sequence of " { $instance word } "s" } } { "width" integer } { "lines" "a sequence of sequences of words" } }
{ $description "Divides the words into lines, where the sum of the lengths of the words on a line (not counting breaks at the end of the line) is at most the given width. Every line except for the first one starts with a non-break, and every one but the last ends with a break." } ;

HELP: word
{ $class-description "A word, for the purposes of " { $vocab-link "wrap" } ", is a Factor object annotated with a length (in the " { $snippet "width" } " slot) and knowledge about whether it is an allowable position for an optional line break (in the " { $snippet "break?" } " slot). Words can be created with " { $link <word> } "." }
{ $see-also wrap } ;

HELP: <word>
{ $values { "key" object } { "width" integer } { "break?" { { $link t } " or " { $link POSTPONE: f } } } { "word" word } }
{ $description "Creates a " { $link word } " object with the given parameters." }
{ $see-also wrap } ;
