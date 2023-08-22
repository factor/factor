! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data io strings byte-arrays ;
IN: xml

HELP: string>xml
{ $values { "string" string } { "xml" xml } }
{ $description "Converts a string into an " { $link xml }
    " tree for further processing." } ;

HELP: read-xml
{ $values { "stream" "an input stream" } { "xml" xml } }
{ $description "Exhausts the given stream, reading an XML document from it. A binary stream, one without encoding, should be used as input, and the encoding is automatically detected." } ;

HELP: file>xml
{ $values { "filename" string } { "xml" xml } }
{ $description "Opens the given file, reads it in as XML, closes the file and returns the corresponding XML tree. The encoding is automatically detected." } ;

HELP: bytes>xml
{ $values { "byte-array" byte-array } { "xml" xml } }
{ $description "Parses a byte array as an XML document. The encoding is automatically detected." } ;

{ string>xml read-xml file>xml bytes>xml } related-words

HELP: read-xml-chunk
{ $values { "stream" "an input stream" } { "seq" "a sequence of elements" } }
{ $description "Rather than parse a document, as " { $link read-xml } " does, this word parses and returns a sequence of XML elements (tags, strings, etc), ie a document fragment. This is useful for pieces of XML which may have more than one main tag. The encoding is not automatically detected, and a stream with an encoding (ie. one which returns strings from " { $link read } ") should be used as input." }
{ $see-also read-xml } ;

HELP: each-element
{ $values { "stream" "an input stream" } { "quot" { $quotation ( xml-elem -- ) } } }
{ $description "Parses the XML document, and whenever an event is encountered (a tag piece, comment, parsing instruction, directive or string element), the quotation is called with that event on the stack. The quotation has all responsibility to deal with the event properly. The encoding of the stream is automatically detected, so a binary input stream should be used." }
{ $see-also read-xml } ;

HELP: pull-xml
{ $class-description "Represents the state of a pull-parser for XML. Has one slot, " { $snippet "scope" } ", which is a namespace which contains all relevant state information." }
{ $see-also <pull-xml> pull-event pull-elem } ;

HELP: <pull-xml>
{ $values { "pull-xml" pull-xml } }
{ $description "Creates an XML pull-based parser which reads from " { $link input-stream } ", executing all initial XML commands to set up the parser." }
{ $see-also pull-xml pull-elem pull-event } ;

HELP: pull-elem
{ $values { "pull" "an XML pull parser" } { "xml-elem/f" "an XML tag, string, or f" } }
{ $description "Gets the next XML element from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-event } ;

HELP: pull-event
{ $values { "pull" "an XML pull parser" } { "xml-event/f" "an XML tag event, string, or f" } }
{ $description "Gets the next XML event from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-elem } ;

HELP: read-dtd
{ $values { "stream" "an input stream" } { "dtd" dtd } }
{ $description "Exhausts a stream, producing a " { $link dtd } " from the contents." } ;

HELP: file>dtd
{ $values { "filename" string } { "dtd" dtd } }
{ $description "Reads a file in UTF-8, converting it into an XML " { $link dtd } "." } ;

HELP: string>dtd
{ $values { "string" string } { "dtd" dtd } }
{ $description "Interprets a string as an XML " { $link dtd } "." } ;

{ read-dtd file>dtd string>dtd } related-words

ARTICLE: { "xml" "reading" } "Reading XML"
"The following words are used to read something into an XML document"
{ $subsections
    read-xml
    read-xml-chunk
    string>xml
    string>xml-chunk
    file>xml
    bytes>xml
}
"To read a DTD:"
{ $subsections
    read-dtd
    file>dtd
    string>dtd
} ;

ARTICLE: { "xml" "events" } "Event-based XML parsing"
    "In addition to DOM-style parsing based around " { $link read-xml } ", the XML module also provides SAX-style event-based parsing. This uses much of the same data structures as normal XML, with the exception of the classes " { $link xml } " and " { $link tag } " and as such, the article " { $vocab-link "xml.data" } " may be useful in learning how to process documents in this way. Other useful words are:"
{ $subsections
    each-element
    opener
    closer
    contained
}
"There is also pull-based parsing to augment the push-parsing of SAX. This is probably easier to use and more logical. It uses the same parsing objects as the above style of parsing, except string elements are always in arrays, for example { \"\" }. Relevant pull-parsing words are:"
{ $subsections
    <pull-xml>
    pull-xml
    pull-event
    pull-elem
} ;

ARTICLE: { "xml" "namespaces" } "Working with XML namespaces"
"The Factor XML parser implements XML namespaces, and provides convenient utilities for working with them. Anywhere in the public API that a name is accepted as an argument, either a string or an XML name is accepted. If a string is used, it is coerced into a name by giving it a null namespace. Names are stored as " { $link name } " tuples, which have slots for the namespace prefix and namespace URL as well as the main part of the tag name." $nl
"To make it easier to create XML names, the parsing word " { $snippet "XML-NS:" } " is provided in the " { $vocab-link "xml.syntax" } " vocabulary." $nl
"When parsing XML, names are automatically augmented with the appropriate namespace URL when the information is available. This does not take into account any XML schema which might allow for such prefixes to be omitted. When generating XML to be written, keep in mind that the XML writer knows only about the literal prefixes and ignores the URLs. It is your job to make sure that they match up correctly, and that there is the appropriate " { $snippet "xmlns" } " declaration." ;

ARTICLE: "xml" "XML parser"
"The " { $vocab-link "xml" } " vocabulary implements the XML 1.0 and 1.1 standards, converting strings of text into XML and vice versa. The parser checks for well-formedness but is not validating. There is only partial support for processing DTDs."
{ $subsections
    { "xml" "reading" }
    { "xml" "events" }
    { "xml" "namespaces" }
}
{ $vocab-subsections
    { "Writing XML" "xml.writer" }
    { "XML parsing errors" "xml.errors" }
    { "XML entities" "xml.entities" }
    { "XML data types" "xml.data" }
    { "Utilities for traversing XML" "xml.traversal" }
    { "Syntax extensions for XML" "xml.syntax" }
} ;

ABOUT: "xml"
