USING: help.markup help.syntax kernel math models sequences
strings ;
IN: documents

HELP: +col
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Adds an integer to the column number of a line/column pair." } ;

{ +col +line =col =line } related-words

HELP: +line
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Adds an integer to the line number of a line/column pair." } ;

HELP: =col
{ $values { "n" integer } { "loc" "a pair of integers" } { "newloc" "a pair of integers" } }
{ $description "Sets the column number of a line/column pair." } ;

HELP: =line
{ $values { "n" integer } { "loc" "a pair of integers" } { "newloc" "a pair of integers" } }
{ $description "Sets the line number of a line/column pair." } ;

HELP: lines-equal?
{ $values { "loc1" "a pair of integers" } { "loc2" "a pair of integers" } { "?" boolean } }
{ $description "Tests if both line/column pairs have the same line number." } ;

HELP: document
{ $class-description "A document is a " { $link model } " containing editable text, stored as an array of lines. Documents are created by calling " { $link <document> } ". Documents can be edited with editor gadgets; see " { $vocab-link "ui.gadgets.editors" } "." } ;

HELP: <document>
{ $values { "document" "a new " { $link document } } }
{ $description "Creates a new, empty " { $link document } "." } ;

HELP: doc-line
{ $values { "n" "a non-negative integer" } { "document" document } { "string" string } }
{ $description "Outputs the " { $snippet "n" } "th line of the document." }
{ $errors "Throws an error if " { $snippet "n" } " is out of bounds." } ;

HELP: doc-lines
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "document" document } { "slice" slice } }
{ $description "Outputs a range of lines from the document." }
{ $notes "The range is created by calling " { $link <slice> } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: each-doc-line
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "quot" { $quotation ( ... line -- ... ) } } }
{ $description "Applies the quotation to each line in the range." }
{ $notes "The range is created by calling " { $link <slice> } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: doc-range
{ $values { "from" "a pair of integers" } { "to" "a pair of integers" } { "document" document } { "string" "a new " { $link string } } }
{ $description "Outputs all text in between two line/column number pairs. Lines are separated by " { $snippet "\\n" } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: set-doc-range
{ $values { "string" string } { "from" "a pair of integers" } { "to" "a pair of integers" } { "document" document } }
{ $description "Replaces all text between two line/column number pairs with " { $snippet "string" } ". The string may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." }
{ $side-effects "document" } ;

HELP: set-doc-range*
{ $values { "string" string } { "from" "a pair of integers" } { "to" "a pair of integers" } { "document" document } }
{ $description "Replaces all text between two line/column number pairs with " { $snippet "string" } ". The string may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators.\n\nThis word differs from " { $link set-doc-range } " in that it does not include changes in the Undo and Redo actions." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." }
{ $side-effects "document" } ;

HELP: remove-doc-range
{ $values { "from" "a pair of integers" } { "to" "a pair of integers" } { "document" document } }
{ $description "Removes all text between two line/column number pairs." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." }
{ $side-effects "document" } ;

HELP: validate-loc
{ $values { "loc" "a pair of integers" } { "document" document } { "newloc" "a pair of integers" } }
{ $description "Ensures that the line and column numbers in " { $snippet "loc" } " are valid, clamping them to the permitted range if they are not." } ;

HELP: line-end
{ $values { "line#" "a non-negative integer" } { "document" document } { "loc" "a pair of integers" } }
{ $description "Outputs the location where " { $snippet "line#" } " ends." }
{ $errors "Throws an error if " { $snippet "line#" } " is out of bounds." } ;

HELP: doc-end
{ $values { "document" document } { "loc" "a pair of integers" } }
{ $description "Outputs the location of the end of the document." } ;

HELP: doc-string
{ $values { "document" document } { "str" "a new " { $link string } } }
{ $description "Outputs the contents of the document as a string. Lines are separated by " { $snippet "\\n" } "." } ;

HELP: set-doc-string
{ $values { "string" string } { "document" document } }
{ $description "Sets the contents of the document to a string, which may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators." }
{ $side-effects "document" } ;

HELP: clear-doc
{ $values { "document" document } }
{ $description "Removes all text from the document." }
{ $side-effects "document" } ;

ARTICLE: "documents" "Documents"
"The " { $vocab-link "documents" } " vocabulary implements " { $emphasis "documents" } ", which are models storing a passage of text as a sequence of lines. Operations are defined for operating on subranges of the text, and " { $link "ui.gadgets.editors" } " can display these models."
{ $subsections
    document
    <document>
}
"Getting and setting the contents of the entire document:"
{ $subsections
    doc-string
    set-doc-string
    clear-doc
}
"Getting and setting subranges:"
{ $subsections
    doc-line
    doc-lines
    doc-range
    set-doc-range
    remove-doc-range
}
"A combinator:"
{ $subsections
    each-doc-line
    map-doc-lines
}
"More info:"
{ $subsections
    "document-locs"
    "documents.elements"
}
{ $see-also "ui.gadgets.editors" } ;

ARTICLE: "document-locs" "Document locations"
"Locations in the document are represented as a line/column number pair, with both indices being zero-based. There are some words for manipulating locations:"
{ $subsections
    +col
    +line
    =col
    =line
}
"Miscellaneous words for working with locations:"
{ $subsections
    lines-equal?
    validate-loc
} ;

ABOUT: "documents"
