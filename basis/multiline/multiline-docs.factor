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

HELP: HEREDOC:
{ $syntax "HEREDOC: marker\n...text...marker" }
{ $values { "marker" "a word (token)" } { "text" "arbitrary text" } { "" "a string" } }
{ $description "A multiline string syntax with a user-specified terminating delimiter.  HEREDOC: reads the next word, and uses it as the 'close quote'.  All input from the beginning of the HEREDOC:'s next line, until the first appearance of the word's name, becomes a string.  The terminating word does not need to be at the beginning of a line.\n\nThe HEREDOC: line should not have anything after the delimiting word.  The delimiting word should be an alphanumeric token.  It should not be, as in some other languages, a \"quoted string\"." }
{ $examples
    { $example "USING: multiline prettyprint ;"
               "HEREDOC: END\nx\nEND ."
               "\"x\\n\""
    }
    { $example "USING: multiline prettyprint ;"
               "HEREDOC: END\nxEND ."
               "\"x\""
    }
    { $example "USING: multiline prettyprint sequences ;"
               "2 5 HEREDOC: zap\nfoo\nbarzap subseq ."
               "\"o\\nb\""
    }
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
{ $subsection POSTPONE: HEREDOC: }
"Multiline comments:"
{ $subsection POSTPONE: /* }
"Writing new multiline parsing words:"
{ $subsection parse-multiline-string }
;

ABOUT: "multiline"
