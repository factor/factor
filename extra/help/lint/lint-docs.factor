USING: help.markup help.syntax ;
IN: help.lint

HELP: check-help
{ $description "Checks all word and article help." } ;

HELP: check-vocab-help
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Checks all word help in the given vocabulary." } ;

ARTICLE: "help.lint" "Help lint tool"
"The " { $vocab-link "help.lint" } " vocabulary implements a tool to check documentation in an automated fashion. You should use this tool to check any documentation that you write."
$nl
"To run help lint, use one of the following two words:"
{ $subsection check-help }
{ $subsection check-vocab-help }
"Help lint performs the following checks:"
{ $list
    "ensures examples run and produce stated output"
    { "ensures " { $link $see-also } " elements don't contain duplicate entries" }
    { "ensures " { $link $vocab-link } " elements point to modules which actually exist" }
    { "ensures that " { $link $values } " match the stack effect declaration" }
    { "ensures that word help articles actually render (this catches broken links, improper nesting, etc)" }
} ;

ABOUT: "help.lint"
