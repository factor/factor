USING: help.markup help.syntax strings ;
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
{ $syntax "HEREDOC: marker\n...text...\nmarker" }
{ $values { "marker" "a word (token)" } { "text" "arbitrary text" } { "value" string } }
{ $description "Returns a string delimited by an arbitrary user-defined token. This delimiter must be exactly the text beginning at the first non-blank character after the " { $link POSTPONE: HEREDOC: } " until the end of the line containing the " { $link POSTPONE: HEREDOC: } ". Text is captured until a line is found conatining exactly this delimter string." }
{ $warning "Whitespace is significant." }
{ $examples
    { $example "USING: multiline prettyprint ;"
               "HEREDOC: END\nx\nEND\n."
               "\"x\\n\""
    }
    { $example "USING: multiline prettyprint sequences ;"
               "2 5 HEREDOC: zap\nfoo\nbar\nzap\nsubseq ."
               "\"o\\nb\""
    }
} ;

HELP: DELIMITED:
{ $syntax "DELIMITED: marker\n...text...\nmarker" }
{ $values { "marker" "a word (token)" } { "text" "arbitrary text" } { "value" string } }
{ $description "Returns a string delimited by an arbitrary user-defined token. This delimiter must be exactly the text beginning at the first non-blank character after the " { $link POSTPONE: DELIMITED: } " until the end of the line containing the " { $link POSTPONE: DELIMITED: } ". Text is captured until the exact delimiter string is found, regardless of where." }
{ $examples
    { $example "USING: multiline prettyprint ;"
               "DELIMITED: factor blows my mind"
"whoafactor blows my mind ."
                "\"whoa\""
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
{ $subsection POSTPONE: DELIMITED: }
"Multiline comments:"
{ $subsection POSTPONE: /* }
"Writing new multiline parsing words:"
{ $subsection parse-multiline-string }
;

ABOUT: "multiline"
