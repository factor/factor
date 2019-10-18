USING: help.markup help.crossref help.topics help.syntax
definitions io prettyprint inspector ;
IN: help

ARTICLE: "printing-elements" "Printing markup elements"
"When writing documentation, it is useful to be able to print markup elements for testing purposes. Markup elements which are strings or arrays of elements are printed in the obvious way. Markup elements of the form " { $snippet "{ $directive content... }" } " are printed by executing the " { $snippet "$directive" } " word with the element content on the stack."
{ $subsection print-element }
{ $subsection print-content } ;

ARTICLE: "span-elements" "Span elements"
{ $subsection $emphasis }
{ $subsection $strong }
{ $subsection $link }
{ $subsection $vocab-link }
{ $subsection $snippet }
{ $subsection $url } ;

ARTICLE: "block-elements" "Block elements"
"Paragraph break:"
{ $subsection $nl }
"Standard headings for word documentation:"
{ $subsection $values }
{ $subsection $description }
{ $subsection $class-description }
{ $subsection $error-description }
{ $subsection $var-description }
{ $subsection $contract }
{ $subsection $examples }
{ $subsection $warning }
{ $subsection $notes }
{ $subsection $side-effects }
{ $subsection $errors }
{ $subsection $see-also }
"Boilerplate paragraphs:"
{ $subsection $low-level-note }
{ $subsection $io-error }
"Some additional elements:"
{ $subsection $code }
{ $subsection $curious }
{ $subsection $example }
{ $subsection $heading }
{ $subsection $links }
{ $subsection $list }
{ $subsection $markup-example }
{ $subsection $references }
{ $subsection $see }
{ $subsection $subsection }
{ $subsection $table } ;

ARTICLE: "markup-utils" "Markup element utilities"
"Utility words to assist in defining new elements:"
{ $subsection simple-element }
{ $subsection ($span) }
{ $subsection ($block) } ;

ARTICLE: "element-types" "Element types"
"Markup elements can be classified into two broad categories, block elements and span elements. Block elements are inset with newlines before and after, whereas span elements flow with the paragraph text."
{ $subsection "span-elements" }
{ $subsection "block-elements" }
{ $subsection "markup-utils" } ;

ARTICLE: "browsing-help" "Browsing documentation"
"The easiest way to browse the help is from the help browser tool in the UI, however you can also display help topics in the listener. Help topics are identified by article name strings, or words. You can request a specific help topic:"
{ $subsection help }
"You can also display the main help article for a vocabulary:"
{ $subsection about } ;

ARTICLE: "writing-help" "Writing documentation"
"By convention, documentation is written in files whose names end with " { $snippet "-docs.factor" } ". Vocabulary documentation should be placed in the same directory as the vocabulary source code; see " { $link "vocabs.loader" } "."
$nl
"A pair of parsing words are used to define free-standing articles and to associate documentation with words:"
{ $subsection POSTPONE: ARTICLE: }
{ $subsection POSTPONE: HELP: }
"A parsing word defines the main help article for a vocabulary:"
{ $subsection POSTPONE: ABOUT: }
"The " { $emphasis "content" } " in both cases is a " { $emphasis "markup element" } ", a recursive structure taking one of the following forms:"
{ $list
    { "a string," }
    { "an array of markup elements," }
    { "or an array of the form " { $snippet "{ $directive content... }" } ", where " { $snippet "$directive" } " is a markup word whose name starts with " { $snippet "$" } ", and " { $snippet "content..." } " is a series of markup elements" }
}
{ $subsection "element-types" }
"Related words can be cross-referenced:"
{ $subsection related-words } ;

ARTICLE: "help-impl" "Help system implementation"
"Help topic protocol:"
{ $subsection article-name }
{ $subsection article-title }
{ $subsection article-content }
{ $subsection article-parent }
{ $subsection set-article-parent }
"Boilerplate word help can be automatically generated (for example, slot accessor help):"
{ $subsection word-help }
{ $subsection word-help* }
"Help article implementation:"
{ $subsection article }
{ $subsection articles }
"Links:"
{ $subsection link }
{ $subsection >link }
"Utilities for traversing markup element trees:"
{ $subsection elements }
{ $subsection collect-elements }
"Links and " { $link article } " instances implement the definition protocol; refer to " { $link "definitions" } "." ;

ARTICLE: "help" "Help system"
"The help system maintains documentation written in a simple markup language, along with cross-referencing and search. Documentation can either exist as free-standing " { $emphasis "articles" } " or be associated with words."
{ $subsection "browsing-help" }
{ $subsection "writing-help" }
{ $subsection "help-impl" } ;

ABOUT: "help"

HELP: $title
{ $values { "topic" "a help article name or a word" } }
{ $description "Prints a help article's title, or a word's " { $link summary } ", depending on the type of " { $snippet "topic" } "." } ;

HELP: help
{ $values { "topic" "an article name or a word" } }
{ $description
    "Displays a help article or documentation associated to a word on the " { $link stdio } " stream."
} ;

HELP: about
{ $values { "vocab" "a vocabulary specifier" } }
{ $description
    "Displays the main help article for the vocabulary. The main help article is set with the " { $link POSTPONE: ABOUT: } " parsing word."
} ;

HELP: :help
{ $description "Displays documentation for the most recent error." } ;

HELP: $subsection
{ $values { "element" "a markup element of the form " { $snippet "{ topic }" } } }
{ $description "Prints a large clickable link to the help topic named by the first string element of " { $snippet "element" } "." }
{ $examples
    { $code "{ $subsection \"sequences\" }" }
} ;

HELP: $index
{ $values { "element" "a markup element containing one quotation with stack effect " { $snippet "( quot -- )" } } }
{ $description "Calls the quotation to generate a sequence of help topics, and outputs a " { $link $subsection } " for each one." } ;

HELP: ($index)
{ $values { "seq" "a sequence of help article names and words" } { "quot" "a quotation with stack effect " { $snippet "( topic -- )" } } }
{ $description "Writes a list of " { $link $subsection } " elements to the " { $link stdio } " stream." } ;

HELP: xref-help
{ $description "Update help cross-referencing. Usually this is done automatically." } ;

HELP: sort-articles
{ $values { "seq" "a sequence of help topics" } { "newseq" "a sequence of help topics" } }
{ $description "Sorts a sequence of help topics." } ;

{ article-children article-parent xref-help } related-words
