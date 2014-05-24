USING: help help.crossref help.markup help.syntax io.styles
sequences strings words ;
IN: help.topics

HELP: articles
{ $var-description "Hashtable mapping article names to " { $link article } " instances." } ;

HELP: no-article
{ $values { "name" "an article name" } }
{ $description "Throws a " { $link no-article } " error." }
{ $error-description "Thrown by " { $link help } " if the given help topic does not exist, or if the help topic being displayed links to a help topic which does not exist." } ;

HELP: lookup-article
{ $values { "name" "an article name" } { "article" "an " { $link article } " object" } }
{ $description "Outputs a named " { $link article } " object." } ;

HELP: article-title
{ $values { "topic" "an article name or a word" } { "string" string } }
{ $description "Outputs the title of a specific help article." } ;

HELP: article-content
{ $values { "topic" "an article name or a word" } { "content" "a markup element" } }
{ $description "Outputs the content of a specific help article." } ;

HELP: all-articles
{ $values { "seq" sequence } }
{ $description "Outputs a sequence of all help article names, and all words with documentation." } ;

HELP: elements
{ $values { "elt-type" word } { "element" "a markup element" } { "seq" "a new sequence" } }
{ $description "Outputs a sequence of all elements of type " { $snippet "elt-type" } " found by traversing " { $snippet "element" } "." } ;

HELP: collect-elements
{ $values { "element" "a markup element" } { "seq" "a sequence of words" } { "elements" "a new sequence" } }
{ $description "Collects the arguments of all sub-elements of " { $snippet "element" } " whose markup element type occurs in " { $snippet "seq" } "." }
{ $notes "Used to implement " { $link article-children } "." } ;

HELP: link
{ $class-description "Class of help article presentations. Instances can be passed to " { $link write-object } " to output a clickable hyperlink. Also, instances of this class are valid definition specifiers; see " { $link "definitions" } "." } ;

HELP: related-words
{ $values { "seq" "a sequence of words" } }
{ $description "Defines a set of related words. Each word's documentation will contain links to all other words in the set." } ;
