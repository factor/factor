IN: http.client.post-data
USING: http http.client.post-data.private help.markup help.syntax kernel ;

HELP: >post-data
{ $values { "object" object } { "post-data" { $maybe post-data } } }
{ $description "Converts an object into a " { $link post-data } " tuple instance." } ;
