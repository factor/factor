USING: fuel.help.private help.markup help.syntax sequences strings words ;
IN: fuel.help

HELP: article-parents
{ $values { "article-name" string } { "parents" sequence } }
{ $description "All the parent articles for the article and ensures that the ancestor always is 'handbook'." } ;

HELP:  get-article
{ $values { "name" string } { "element" string } }
{ $description "If an article and a vocab share name, we render the vocab instead." } ;

HELP: find-word
{ $values { "name" string } { "word/f" { $maybe word } } }
{ $description "Prefer to use search which takes the execution context into account. If that fails, fall back on a search of all words." } ;

HELP: vocab-element
{ $values { "name" string } { "element" sequence } }
{ $description "Creates help markup for a vocab suitable for rendering with FUEL." }
{ $see-also article-element word-element } ;

HELP: get-vocabs/tag
{ $values { "tag" string } { "element" sequence } }
{ $description "Creates help markup for a page listing all vocabs with a given tag." } ;
