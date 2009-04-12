USING: help.markup help.syntax ;
IN: help.lint

HELP: help-lint-all
{ $description "Checks all word help and articles in all loaded vocabularies." } ;

HELP: help-lint
{ $values { "prefix" "a vocabulary specifier" } }
{ $description "Checks all word help and articles in the given vocabulary and all child vocabularies." } ;

ARTICLE: "help.lint" "Help lint tool"
"The " { $vocab-link "help.lint" } " vocabulary implements a tool to check documentation in an automated fashion. You should use this tool to check any documentation that you write."
$nl
"To run help lint, use one of the following two words:"
{ $subsection help-lint }
{ $subsection help-lint-all }
"Once a help lint run completes, failures can be listed:"
{ $subsection :lint-failures }
"Help lint failures are also shown in the " { $link "ui.tools.error-list" } "."
$nl
"Help lint performs the following checks:"
{ $list
    "ensures examples run and produce stated output"
    { "ensures " { $link $see-also } " elements don't contain duplicate entries" }
    { "ensures " { $link $vocab-link } " elements point to modules which actually exist" }
    { "ensures that " { $link $values } " match the stack effect declaration" }
    { "ensures that help topics actually render (this catches broken links, improper nesting, etc)" }
} ;

ABOUT: "help.lint"
