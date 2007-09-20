USING: help.markup help.syntax math models strings sequences ;
IN: documents

HELP: +col
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Adds an integer to the column number of a line/column pair." } ;

{ +col +line =col =line } related-words

HELP: +line
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Adds an integer to the line number of a line/column pair." } ;

HELP: =col
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Sets the column number of a line/column pair." } ;

HELP: =line
{ $values { "loc" "a pair of integers" } { "n" integer } { "newloc" "a pair of integers" } }
{ $description "Sets the line number of a line/column pair." } ;

HELP: lines-equal?
{ $values { "loc1" "a pair of integers" } { "loc2" "a pair of integers" } { "?" "a boolean" } }
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

HELP: each-line
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "quot" "a quotation with stack effect " { $snippet "( string -- )" } } }
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
{ $description "Sets the contents of the document to a string,  which may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators." }
{ $side-effects "document" } ;

HELP: clear-doc
{ $values { "document" document } }
{ $description "Removes all text from the document." }
{ $side-effects "document" } ;

HELP: prev-elt
{ $values { "loc" "a pair of integers" } { "document" document } { "elt" "an element" } { "newloc" "a pair of integers" } }
{ $contract "Outputs the location of the first occurrence of the element prior to " { $snippet "loc" } "." } ;

{ prev-elt next-elt } related-words

HELP: next-elt
{ $values { "loc" "a pair of integers" } { "document" document } { "elt" "an element" } { "newloc" "a pair of integers" } }
{ $contract "Outputs the location of the first occurrence of the element following " { $snippet "loc" } "." } ;

HELP: char-elt
{ $class-description "An element representing a single character." } ;

HELP: one-word-elt
{ $class-description "An element representing a single word. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the beginning and the end of the word at the current location." } ;

{ one-word-elt word-elt } related-words

HELP: word-elt
{ $class-description "An element representing a single word. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next word from the current location." } ;

HELP: one-line-elt
{ $class-description "An element representing a single line. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the beginning and the end of the line at the current location." } ;

{ one-line-elt line-elt } related-words

HELP: line-elt
{ $class-description "An element representing a single line. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next line from the current location." } ;

HELP: doc-elt
{ $class-description "An element representing the entire document. The " { $link prev-elt } " word outputs the start of the document and the " { $link next-elt } " word outputs the end of the document." } ;

ARTICLE: "documents" "Documents"
{ $subsection document }
{ $subsection <document> }
"Getting and setting the contents of the entire document:"
{ $subsection doc-string }
{ $subsection set-doc-string }
{ $subsection clear-doc }
"Getting and setting subranges:"
{ $subsection doc-line }
{ $subsection doc-lines }
{ $subsection doc-range }
{ $subsection set-doc-range }
{ $subsection remove-doc-range }
"A combinator:"
{ $subsection each-line }
{ $see-also "gadgets-editors" } ;

ARTICLE: "document-locs-elts" "Locations and elements"
"Locations in the document are represented as a line/column number pair, with both indices being zero-based. There are some words for manipulating locations:"
{ $subsection +col }
{ $subsection +line }
{ $subsection =col }
{ $subsection =line }
"New locations can be created out of existing ones by finding the start or end of a document element nearest to a given location."
{ $subsection prev-elt }
{ $subsection next-elt }
"The different types of document elements correspond to the standard editing taxonomy:"
{ $subsection char-elt }
{ $subsection one-word-elt }
{ $subsection word-elt }
{ $subsection one-line-elt }
{ $subsection line-elt }
{ $subsection doc-elt }
"Miscellaneous words for working with locations:"
{ $subsection lines-equal? }
{ $subsection validate-loc } ;
