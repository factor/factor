USING: help.markup help.syntax multiline ;

HELP: STRING:
{ $syntax "STRING: name\nfoo\n;" }
{ $description "Forms a multiline string literal, or 'here document' stored in the word called name. A semicolon is used to signify the end, and that semicolon must be on a line by itself, not preceeded or followed by any whitespace. The string will have newlines in between lines but not at the end, unless there is a blank line before the semicolon." } ;

HELP: <"
{ $syntax "<\" text \">" }
{ $description "This forms a multiline string literal ending in \">. Unlike the " { $link POSTPONE: STRING: } " form, you can end it in the middle of a line. This construct is non-nesting. In the example above, the string would be parsed as \"text\"." } ;

{ POSTPONE: <" POSTPONE: STRING: } related-words

HELP: parse-here
{ $values { "str" "a string" } }
{ $description "Parses a multiline string literal, as used by " { $link POSTPONE: STRING: } "." } ;

HELP: parse-multiline-string
{ $values { "end-text" "a string delineating the end" } { "str" "the parsed string" } }
{ $description "Parses a multiline string literal, as used by " { $link POSTPONE: <" } ". The end-text is the delimiter for the end." } ;

{ parse-here parse-multiline-string } related-words
