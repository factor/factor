USING: help.markup help.syntax ;
IN: help.lint

ARTICLE: "help.lint" "Help lint tool"
"A quick and dirty tool to check documentation in an automated fashion."
{ $list
    "ensures examples run and produce stated output"
    { "ensures " { $link $see-also } " elements don't contain duplicate entries" }
    { "ensures " { $link $vocab-link } " elements point to modules which actually exist" }
    { "ensures that " { $link $values } " match the stack effect declaration" }
    { "ensures that word help articles actually render (this catches broken links, improper nesting, etc)" }
} ;

ABOUT: "help.lint"
