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
"Additionally, the vocabulary provides capabilities to wrap arbitrary groups of things, in units called segments."
{ $subsection wrap-segments }
{ $subsection segment }
{ $subsection <segment> } ;

HELP: wrap-lines
{ $values { "lines" string } { "width" integer } { "newlines" "sequence of strings" } }
{ $description "Given a string, divides it into a sequence of lines where each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-string
{ $values { "string" string } { "width" integer } { "newstring" string } }
{ $description "Given a string, alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-indented-string
{ $values { "string" string } { "width" integer } { "indent" string } { "newstring" string } }
{ $description "Given a string, alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space. Before each line, the indent string is added." } ;

HELP: wrap-segments
{ $values { "segments" { "a sequence of " { $instance segment } "s" } } { "line-max" integer } { "line-ideal" integer } { "lines" "a sequence of sequences of words" } }
{ $description "Divides the words into lines, where the sum of the lengths of the words on a line (not counting breaks at the end of the line) is at most the given maximum. The returned set of lines is optimized to minimize the square of the deviation of each line from the ideal width. It is not guaranteed to be the minimal number of lines. Every line except for the first one starts with a non-break, and every one but the last ends with a break." } ;

HELP: segment
{ $class-description "A segment is a Factor object annotated with a length (in the " { $snippet "width" } " slot) and knowledge about whether it is an allowable position for an optional line break (in the " { $snippet "break?" } " slot). Elements can be created with " { $link <segment> } "." }
{ $see-also wrap-segments } ;

HELP: <segment>
{ $values { "key" object } { "width" integer } { "break?" { { $link t } " or " { $link POSTPONE: f } } } { "segment" segment } }
{ $description "Creates a " { $link segment } " object with the given parameters." }
{ $see-also wrap-segments } ;
