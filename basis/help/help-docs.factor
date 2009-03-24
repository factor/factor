USING: help.markup help.crossref help.stylesheet help.topics
help.syntax definitions io prettyprint summary arrays math
sequences vocabs strings see ;
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
{ $subsection $slot }
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
"Elements used in " { $link $values } " forms:"
{ $subsection $instance }
{ $subsection $maybe }
{ $subsection $or }
{ $subsection $quotation }
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

IN: help.markup
ABOUT: "element-types"

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
"Here is a more formal schema for the help markup language:"
{ $code
"<element> ::== <string> | <simple-element> | <fancy-element>"
"<simple-element> ::== { <element>* }"
"<fancy-element> ::== { <type> <element> }"
}
{ $subsection "element-types" }
{ $subsection "printing-elements" }
"Related words can be cross-referenced:"
{ $subsection related-words }
{ $see-also "help.lint" } ;

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
{ $subsection "help.lint" }
{ $subsection "tips-of-the-day" }
{ $subsection "help-impl" } ;

IN: help
ABOUT: "help"

HELP: $title
{ $values { "topic" "a help article name or a word" } }
{ $description "Prints a help article's title, or a word's " { $link summary } ", depending on the type of " { $snippet "topic" } "." } ;

HELP: print-topic
{ $values { "topic" "an article name or a word" } }
{ $description
    "Displays a help topic on " { $link output-stream } "."
} ;

HELP: help
{ $values { "topic" "an article name or a word" } }
{ $description
    "Displays a help topic."
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
{ $values { "articles" "a sequence of help articles" } }
{ $description "Writes a list of " { $link $subsection } " elements to " { $link output-stream } "." } ;

HELP: xref-help
{ $description "Update help cross-referencing. Usually this is done automatically." } ;

HELP: sort-articles
{ $values { "seq" "a sequence of help topics" } { "newseq" "a sequence of help topics" } }
{ $description "Sorts a sequence of help topics." } ;

{ article-children article-parent xref-help } related-words

HELP: $predicate
{ $values { "element" "a markup element of the form " { $snippet "{ word }" } } }
{ $description "Prints the boilerplate description of a class membership predicate word such as " { $link array? } " or " { $link integer? } "." } ;

HELP: print-element
{ $values { "element" "a markup element" } }
{ $description "Prints a markup element to " { $link output-stream } "." } ;

HELP: print-content
{ $values { "element" "a markup element" } }
{ $description "Prints a top-level markup element to " { $link output-stream } "." } ;

HELP: simple-element
{ $class-description "Class of simple elements, which are just arrays of elements." } ;

HELP: ($span)
{ $values { "quot" "a quotation" } }
{ $description "Prints an inline markup element." } ;

HELP: ($block)
{ $values { "quot" "a quotation" } }
{ $description "Prints a block markup element with newlines before and after." } ;

HELP: $heading
{ $values { "element" "a markup element" } }
{ $description "Prints a markup element, usually a string, as a block with the " { $link heading-style } "." }
{ $examples
    { $markup-example { $heading "What remains to be discovered" } }
} ;

HELP: $subheading
{ $values { "element" "a markup element of the form " { $snippet "{ title content }" } } }
{ $description "Prints a markup element, usually a string, as a block with the " { $link strong-style } "." }
{ $examples
    { $markup-example { $subheading "Developers, developers, developers!" } }
} ;

HELP: $code
{ $values { "element" "a markup element of the form " { $snippet "{ string... }" } } }
{ $description "Prints code examples, as seen in many help articles. The markup element must be an array of strings." }
{ $notes
    "The code becomes clickable if the output stream supports it, and clicking it opens a listener window with the text inserted at the input prompt."
    $nl
    "If you want to show code along with sample output, use the " { $link $example } " element."
}
{ $examples
    { $markup-example { $code "2 2 + ." } }
} ;

HELP: $nl
{ $values { "children" "unused parameter" } }
{ $description "Prints a paragraph break. The parameter is unused." } ;

HELP: $snippet
{ $values { "children" "markup elements" } }
{ $description "Prints a key word or otherwise notable snippet of text, such as a type or a word input parameter. To document slot names, use " { $link $slot } "." } ;

HELP: $slot
{ $values { "children" "markup elements" } }
{ $description "Prints a tuple slot name in the same way as a snippet. The help tool can check that there exists an accessor with this name." } ;

HELP: $vocabulary
{ $values { "element" "a markup element of the form " { $snippet "{ word }" } } }
{ $description "Prints a word's vocabulary. This markup element is automatically output by the help system, so help descriptions of parsing words should not call it." } ;

HELP: $description
{ $values { "element" "a markup element" } }
{ $description "Prints the description subheading found on the help page of most words." } ;

HELP: $contract
{ $values { "element" "a markup element" } }
{ $description "Prints a heading followed by a contract, found on the help page of generic words. Every generic word should document a contract which specifies method behavior that callers can rely upon, and implementations must obey." }
{ $examples
    { $markup-example { $contract "Methods of this generic word must always crash." } }
} ;

HELP: $examples
{ $values { "element" "a markup element" } }
{ $description "Prints a heading followed by some examples. Word documentation should include examples, at least if the usage of the word is not entirely obvious." }
{ $examples
    { $markup-example { $examples { $example "USING: math prettyprint ;" "2 2 + ." "4" } } }
} ;

HELP: $example
{ $values { "element" "a markup element of the form " { $snippet "{ inputs... output }" } } }
{ $description "Prints a clickable example with sample output. The markup element must be an array of strings. All but the last string are joined by newlines and taken as the input text, and the last string is the output. The example becomes clickable if the output stream supports it, and clicking it opens a listener window with the input text inserted at the input prompt." }
{ $examples
    "The input text must contain a correct " { $link POSTPONE: USING: } " declaration, and output text should be a string of what the input prints when executed, not the final stack contents or anything like that. So the following is an incorrect example:"
    { $markup-example { $unchecked-example "2 2 +" "4" } }
    "However the following is right:"
    { $markup-example { $example "USING: math prettyprint ;" "2 2 + ." "4" } }
    "Examples can incorporate a call to " { $link .s } " to show multiple output values; the convention is that you may assume the stack is empty before the example evaluates."
} ;

HELP: $markup-example
{ $values { "element" "a markup element" } }
{ $description "Prints a clickable example showing the prettyprinted source text of " { $snippet "element" } " followed by rendered output. The example becomes clickable if the output stream supports it." }
{ $examples
    { $markup-example { $markup-example { $emphasis "Hi" } } }
} ;

HELP: $warning
{ $values { "element" "a markup element" } }
{ $description "Prints an element inset in a block styled as so to draw the reader's attention towards it." }
{ $examples
    { $markup-example { $warning "Incorrect use of this product may cause serious injury or death." } }
} ;

HELP: $link
{ $values { "element" "a markup element of the form " { $snippet "{ topic }" } } }
{ $description "Prints a link to a help article or word." }
{ $examples
    { $markup-example { $link "dlists" } }
    { $markup-example { $link + } }
} ;

HELP: textual-list
{ $values { "seq" "a sequence" } { "quot" { $quotation "( elt -- )" } } }
{ $description "Applies the quotation to each element of the sequence, printing a comma between each pair of elements." }
{ $examples
    { $example "USING: help.markup io ;" "{ \"fish\" \"chips\" \"salt\" } [ write ] textual-list" "fish, chips, salt" }
} ;

HELP: $links
{ $values { "topics" "a sequence of article names or words" } }
{ $description "Prints a series of links to help articles or word documentation." }
{ $notes "This markup element is used to implement " { $link $links } "." }
{ $examples
    { $markup-example { $links + - * / } }
} ;

HELP: $see-also
{ $values { "topics" "a sequence of article names or words" } }
{ $description "Prints a heading followed by a series of links." }
{ $examples
    { $markup-example { $see-also "graphs" "dlists" } }
} ;

{ $see-also $related related-words } related-words

HELP: $table
{ $values { "element" "an array of arrays of markup elements" } }
{ $description "Prints a table given as an array of rows, where each row must have the same number of columns." }
{ $examples
    { $markup-example
        { $table
            { "a" "b" "c" }
            { "d" "e" "f" }
        }
    }
} ;

HELP: $values
{ $values { "element" "an array of pairs of markup elements" } }
{ $description "Prints the description of arguments and values found on every word help page. The first element of a pair is the argument name and is output with " { $link $snippet } ". The remainder is either a single class word, or an element. If it is a class word " { $snippet "class" } ", it is inserted as if it were shorthand for " { $snippet "{ $instance class }" } "." }
{ $see-also $maybe $instance $quotation } ;

HELP: $instance
{ $values { "element" "an array with shape " { $snippet "{ class }" } } }
{ $description
    "Produces the text “a " { $emphasis "class" } "” or “an " { $emphasis "class" } "”, depending on the first letter of " { $emphasis "class" } "."
}
{ $examples
    { $markup-example { $instance string } }
    { $markup-example { $instance integer } }
    { $markup-example { $instance f } }
} ;

HELP: $maybe
{ $values { "element" "an array with shape " { $snippet "{ class }" } } }
{ $description
    "Produces the text “a " { $emphasis "class" } " or f” or “an " { $emphasis "class" } " or f”, depending on the first letter of " { $emphasis "class" } "."
}
{ $examples
    { $markup-example { $maybe string } }
} ;

HELP: $quotation
{ $values { "element" "an array with shape " { $snippet "{ effect }" } } }
{ $description
    "Produces the text “a quotation with stack effect " { $emphasis "effect" } "”."
}
{ $examples
    { $markup-example { $quotation "( obj -- )" } }
} ;

HELP: $list
{ $values { "element" "an array of markup elements" } }
{ $description "Prints a bulleted list of markup elements." }
{ $notes
    "A common mistake is that if an item consists of more than just a string, it will be broken up as several items:"
    { $markup-example
        { $list
            "First item"
            "Second item " { $emphasis "with emphasis" }
        }
    }
    "The fix is easy; just group the two markup elements making up the second item into one markup element:"
    { $markup-example
        { $list
            "First item"
            { "Second item " { $emphasis "with emphasis" } }
        }
    }
} ;

HELP: $errors
{ $values { "element" "a markup element" } }
{ $description "Prints the errors subheading found on the help page of some words. This section should document any errors thrown by the word." }
{ $examples
    { $markup-example { $errors "I/O errors, network errors, hardware errors... oh my!" } }
} ;

HELP: $side-effects
{ $values { "element" "a markup element of the form " { $snippet "{ string... }" } } }
{ $description "Prints a heading followed by a list of input values or variables which are modified by the word being documented." }
{ $examples
    { $markup-example
        { { $values { "seq" "a mutable sequence" } } { $side-effects "seq" } }
    }
} ;

HELP: $notes
{ $values { "element" "a markup element" } }
{ $description "Prints the notes subheading found on the help page of some words. This section should document usage tips and pitfalls." } ;

HELP: $see
{ $values { "element" "a markup element of the form " { $snippet "{ word }" } } }
{ $description "Prints the definition of " { $snippet "word" } " by calling " { $link see } "." }
{ $examples
    { $markup-example { "Here is a word definition:" { $see reverse } } }
} ;

HELP: $definition
{ $values { "element" "a markup element of the form " { $snippet "{ word }" } } }
{ $description "Prints a heading followed by the definition of " { $snippet "word" } " by calling " { $link see } "." } ;

HELP: $curious
{ $values { "element" "a markup element" } }
{ $description "Prints a heading followed by a markup element." }
{ $notes "This element type is used by the cookbook-style introductory articles in the " { $link "handbook" } "." } ;

HELP: $references
{ $values { "element" "a markup element of the form " { $snippet "{ topic... }" } } }
{ $description "Prints a heading followed by a series of links." }
{ $notes "This element type is used by the cookbook-style introductory articles in the " { $link "handbook" } "." } ;

HELP: HELP:
{ $syntax "HELP: word content... ;" }
{ $values { "word" "a word" } { "content" "markup elements" } }
{ $description "Defines documentation for a word." }
{ $examples
    { $code
        ": foo 2 + ;"
        "HELP: foo"
        "{ $values { \"m\" \"an integer\" } { \"n\" \"an integer\" } }"
        "{ $description \"Increments a value by 2.\" } ;"
        "\\ foo help"
    }
} ;

HELP: ARTICLE:
{ $syntax "ARTICLE: topic title content... ;" }
{ $values { "topic" "an object" } { "title" "a string" } { "content" "markup elements" } }
{ $description "Defines a help article. String topic names are reserved for core documentation. Contributed modules should name articles by arrays, where the first element of an array identifies the module; for example, " { $snippet "{ \"httpd\" \"intro\" }" } "." }
{ $examples
    { $code
        "ARTICLE: \"example\" \"An example article\""
        "\"Hello world.\" ;"
    }
} ;

HELP: ABOUT:
{ $syntax "ABOUT: article" }
{ $values { "article" "a help article" } }
{ $description "Defines the main documentation article for the current vocabulary." } ;

HELP: vocab-help
{ $values { "vocab-spec" "a vocabulary specifier" } { "help" "a help article" } }
{ $description "Outputs the main help article for a vocabulary. The main help article can be set with " { $link POSTPONE: ABOUT:  } "." } ;
