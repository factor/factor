IN: html.templates.fhtml
USING: help.markup help.syntax ;

HELP: <fhtml>
{ $values { "path" "a pathname string" } { "fhtml" fhtml } }
{ $description "Creates an FHTML template descriptor." } ;

ARTICLE: "html.templates.fhtml" "FHTML templates"
"The " { $vocab-link "html.templates.fhtml" } " vocabulary implements a templating engine which mixes markup with Factor code."
$nl
"FHTML provides an alternative to " { $vocab-link "html.templates.chloe" } " for situations where complex logic must be embedded in the presentation layer of a web application. While this is discouraged for larger applications, it is useful for prototyping as well as simpler applications."
$nl
"The entire syntax of an FHTML template can be summarized as thus: text outside of " { $snippet "<%" } " and " { $snippet "%>" } " is rendered literally. Text inside " { $snippet "<%" } " and " { $snippet "%>" } " is interpreted as Factor source code."
{ $subsections <fhtml> } ;

ABOUT: "html.templates.fhtml"
