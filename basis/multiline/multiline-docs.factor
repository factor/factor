USING: help.markup help.syntax strings ;
IN: multiline

HELP: STRING:
{ $syntax "STRING: name\nfoo\n;" }
{ $description "Forms a multiline string literal, or 'here document' stored in the word called name. A semicolon is used to signify the end, and that semicolon must be on a line by itself, not preceded or followed by any whitespace. The string will have newlines in between lines but not at the end, unless there is a blank line before the semicolon." } ;

HELP: /*
{ $syntax "/* comment */" }
{ $description "Provides C-like comments that can span multiple lines. One caveat is that " { $snippet "/*" } " and " { $snippet "*/" } " are still tokens and must not appear in the comment text itself. Another caveat is that, unlike in C, the whitespace space after the " { $snippet "/*" } " is mandatory." }
{ $examples
    { $example "USING: multiline ;"
           "/* I think that I shall never see"
           "   A poem lovely as a tree. */"
           ""
    }
} ;

HELP: parse-multiline-string
{ $values { "end-text" "a string delineating the end" } { "str" "the parsed string" } }
{ $description "Parses the input stream until the " { $snippet "end-text" } " is reached and returns the parsed text as a string." }
{ $notes "Used to implement " { $link POSTPONE: /* } "." } ;

ARTICLE: "multiline" "Multiline"
"Multiline strings:"
{ $subsections
    POSTPONE: STRING:
    POSTPONE: [[
    POSTPONE: [=[
    POSTPONE: [==[
    POSTPONE: [===[
    POSTPONE: [====[
    POSTPONE: [=====[
}
"Multiline comments:"
{ $subsections POSTPONE: /* }
"Writing new multiline parsing words:"
{ $subsections parse-multiline-string }
;

ABOUT: "multiline"
