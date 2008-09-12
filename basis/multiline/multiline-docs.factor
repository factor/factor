USING: help.markup help.syntax ;
IN: multiline

HELP: STRING:
{ $syntax "STRING: name\nfoo\n;" }
{ $description "Forms a multiline string literal, or 'here document' stored in the word called name. A semicolon is used to signify the end, and that semicolon must be on a line by itself, not preceeded or followed by any whitespace. The string will have newlines in between lines but not at the end, unless there is a blank line before the semicolon." } ;

HELP: <"
{ $syntax "<\" text \">" }
{ $description "This forms a multiline string literal ending in \">. Unlike the " { $link POSTPONE: STRING: } " form, you can end it in the middle of a line. This construct is non-nesting. In the example above, the string would be parsed as \"text\"." } ;

HELP: /*
{ $syntax "/* comment */" }
{ $description "Provides C-like comments that can span multiple lines. One caveat is that " { $snippet "/*" } " and " { $snippet "*/" } " are still tokens and must not abut the comment text itself." }
{ $example "USING: multiline ;"
           "/* I think that I shall never see"
           "   A poem lovely as a tree. */"
           ""
} ;

{ POSTPONE: <" POSTPONE: STRING: } related-words

HELP: parse-multiline-string
{ $values { "end-text" "a string delineating the end" } { "str" "the parsed string" } }
{ $description "Parses the input stream until the " { $snippet "end-text" } " is reached and returns the parsed text as a string." }
{ $notes "Used to implement " { $link POSTPONE: /* } " and " { $link POSTPONE: <" } "." } ;

ARTICLE: "multiline" "Multiline"
"Multiline strings:"
{ $subsection POSTPONE: STRING: }
{ $subsection POSTPONE: <" }
"Multiline comments:"
{ $subsection POSTPONE: /* }
"Writing new multiline parsing words:"
{ $subsection parse-multiline-string }
;

ABOUT: "multiline"
