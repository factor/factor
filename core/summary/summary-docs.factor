IN: summary
USING: kernel strings help.markup help.syntax ;

ARTICLE: "summary" "Converting objects to summary strings"
"A word for getting very brief descriptions of words and general objects:"
{ $subsections summary } ;

HELP: summary
{ $values { "object" object } { "string" string } }
{ $contract "Outputs a brief description of the object." }
{ $notes "New methods can be defined by user code. Most often, this is used with error classes so that " { $link "debugger" } " can print friendlier error messages." } ;

ABOUT: "summary"
