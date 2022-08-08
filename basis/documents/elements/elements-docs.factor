USING: help.markup help.syntax documents ;
IN: documents.elements

HELP: prev-elt
{ $values { "loc" "a pair of integers" } { "document" document } { "elt" "an element" } { "newloc" "a pair of integers" } }
{ $contract "Outputs the location of the first occurrence of the element prior to " { $snippet "loc" } "." } ;

{ prev-elt next-elt } related-words

HELP: next-elt
{ $values { "loc" "a pair of integers" } { "document" document } { "elt" "an element" } { "newloc" "a pair of integers" } }
{ $contract "Outputs the location of the first occurrence of the element following " { $snippet "loc" } "." } ;

HELP: char-elt
{ $class-description "An element representing a single character. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next character from the current location." } ;

HELP: one-char-elt
{ $class-description "An element representing a single character. The " { $link prev-elt } " and " { $link next-elt } " words keep the location at this character." } ;

{ one-char-elt char-elt } related-words

HELP: one-word-elt
{ $class-description "An element representing a single word. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the beginning and the end of the word at the current location." } ;

{ one-word-elt word-elt } related-words

HELP: word-elt
{ $class-description "An element representing a single word. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next word from the current location." } ;

HELP: one-line-elt
{ $class-description "An element representing a single line. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the beginning and the end of the line at the current location." } ;

{ one-line-elt line-elt } related-words

HELP: line-elt
{ $description "An element representing a single line. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next line from the current location." } ;

HELP: paragraph-elt
{ $description "An element representing a single paragraph. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next paragraph from the current location." } ;

HELP: page-elt
{ $description "An element representing a page of lines. The " { $link prev-elt } " and " { $link next-elt } " words return the location of the previous and next page of lines from the current location." } ;

HELP: doc-elt
{ $class-description "An element representing the entire document. The " { $link prev-elt } " word outputs the start of the document and the " { $link next-elt } " word outputs the end of the document." } ;

ARTICLE: "documents.elements" "Document elements"
"Document elements, defined in the " { $vocab-link "documents.elements" } " vocabulary, overlay a hierarchy of structure on top of the flat sequence of characters presented by the document."
$nl
"The different types of document elements correspond to the standard editing taxonomy:"
{ $subsections
    one-char-elt
    char-elt
    one-word-elt
    word-elt
    one-line-elt
    line-elt
    paragraph-elt
    page-elt
    doc-elt
}
"New locations can be created out of existing ones by finding the start or end of a document element nearest to a given location."
{ $subsections
    prev-elt
    next-elt
} ;

ABOUT: "documents.elements"
