USING: help.markup help.syntax help.tips ;
IN: ui.tools.deploy

HELP: deploy-tool
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Opens the graphical deployment tool for the specified vocabulary." }
{ $examples { $code "\"tetris\" deploy-tool" } } ;

ARTICLE: "ui.tools.deploy" "Application deployment UI tool"
"The application deployment UI tool provides a graphical front-end to deployment configuration. Using the tool, you can set deployment options graphically."
$nl
"To start the tool, pass a vocabulary name to a word:"
{ $subsection deploy-tool }
"Alternatively, right-click on a vocabulary presentation in the UI and choose " { $strong "Deploy tool" } " from the resulting popup menu."
{ $see-also "tools.deploy" } ;

TIP: "Generate stand-alone applications from vocabularies with the " { $link "ui.tools.deploy" } "." ;

ABOUT: "ui.tools.deploy"
