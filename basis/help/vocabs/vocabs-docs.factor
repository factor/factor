USING: help help.topics help.markup help.syntax io strings ;
IN: help.vocabs

ARTICLE: "vocab-tags" "Vocabulary tags"
{ $all-tags } ;

ARTICLE: "vocab-authors" "Vocabulary authors"
{ $all-authors } ;

ARTICLE: "vocab-index" "Vocabulary index"
{ $subsections
    "vocab-tags"
    "vocab-authors"
}
{ $vocab "" } ;

HELP: words.
{ $values { "vocab" "a vocabulary name" } }
{ $description "Printings a listing of all the words in a vocabulary, categorized by type." } ;

HELP: about
{ $values { "vocab" "a vocabulary specifier" } }
{ $description
    "Displays the main help article for the vocabulary. The main help article is set with the " { $link POSTPONE: ABOUT: } " parsing word."
} ;

ARTICLE: "browsing-help" "Browsing documentation"
"Help topics are instances of a mixin:"
{ $subsections topic }
"Most commonly, topics are article name strings, or words. You can display a specific help topic:"
{ $subsections help }
"You can also display the help for a vocabulary:"
{ $subsections about }
"To list a vocabulary's words only:"
{ $subsections words. }
{ $examples
  { $code "\"evaluator\" help" }
  { $code "\\ + help" }
  { $code "\"io.files\" about" }
} ;