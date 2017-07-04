USING: fuel.help.private help.markup help.syntax sequences strings ;
IN: fuel.help

HELP: article-parents
{ $values { "article-name" string } {  "parents" sequence } }
{ $description "All the parent articles for the article and ensures that the ancestor always is 'handbook'." } ;

HELP:  get-article
{ $values { "name" string } { "str" string } }
{ $description "If an article and a vocab share name, we render the vocab instead." } ;

HELP: find-word
{ $values { "name" string } { "word/f" "word or f" } }
{ $description "Prefer to use search which takes the execution context into account. If that fails, fall back on a search of all words." } ;
