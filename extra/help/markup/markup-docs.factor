USING: help.syntax help.stylesheet arrays
definitions io math prettyprint sequences ;
IN: help.markup

ABOUT: "element-types"

HELP: print-element
{ $values { "element" "a markup element" } }
{ $description "Prints a markup element to the " { $link stdio } " stream." } ;

HELP: print-content
{ $values { "element" "a markup element" } }
{ $description "Prints a top-level markup element to the " { $link stdio } " stream." } ;

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
    { $markup-example { $examples { $example "2 2 + ." "4" } } }
} ;

HELP: $example
{ $values { "element" "a markup element of the form " { $snippet "{ inputs... output }" } } }
{ $description "Prints a clickable example with sample output. The markup element must be an array of strings. All but the last string are joined by newlines and taken as the input text, and the last string is the output. The example becomes clickable if the output stream supports it, and clicking it opens a listener window with the input text inserted at the input prompt." }
{ $examples
    "The output text should be a string of what the input prints when executed, not the final stack contents or anything like that. So the following is an incorrect example:"
    { $markup-example { $unchecked-example "2 2 +" "4" } }
    "However the following is right:"
    { $markup-example { $example "2 2 + ." "4" } }
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
    { $markup-example { $link "queues" } }
    { $markup-example { $link + } }
} ;

HELP: textual-list
{ $values { "seq" "a sequence" } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Applies the quotation to each element of the sequence, printing a comma between each pair of elements." }
{ $examples
    { $example "USE: help.markup" "{ \"fish\" \"chips\" \"salt\" } [ write ] textual-list" "fish, chips, salt" }
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
    { $markup-example { $see-also "graphs" "queues" } }
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
{ $description "Prints the description of arguments and values found on every word help page. The first element of a pair is the argument name and is output with " { $link $snippet } ". The remainder can be an element of any form." } ;

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
{ $description "Prints the errors subheading found on the help page of some words. This section should usage tips and pitfalls." } ;

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
