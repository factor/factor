! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data io ;
IN: xml

HELP: string>xml
{ $values { "string" "a string" } { "xml" "an xml document" } }
{ $description "converts a string into an " { $link xml }
    " datatype for further processing" } ;

HELP: read-xml
{ $values { "stream" "a stream that supports readln" }
    { "xml" "an XML document" } }
{ $description "exausts the given stream, reading an XML document from it. A binary stream, one without encoding, should be used as input, and the encoding is automatically detected." } ;

HELP: file>xml
{ $values { "filename" "a string representing a filename" }
    { "xml" "an XML document" } }
{ $description "opens the given file, reads it in as XML, closes the file and returns the corresponding XML tree" } ;

{ string>xml read-xml file>xml } related-words

HELP: read-xml-chunk
{ $values { "stream" "an input stream" } { "seq" "a sequence of elements" } }
{ $description "rather than parse a document, as " { $link read-xml } " does, this word parses and returns a sequence of XML elements (tags, strings, etc), ie a document fragment. This is useful for pieces of XML which may have more than one main tag." }
{ $see-also read-xml } ;

HELP: sax
{ $values { "stream" "an input stream" } { "quot" "a quotation ( xml-elem -- )" } }
{ $description "parses the XML document, and whenever an event is encountered (a tag piece, comment, parsing instruction, directive or string element), the quotation is called with that event on the stack. The quotation has all responsibility to deal with the event properly, and it is advised that generic words be used in dispatching on the event class." }
{ $notes "It is important to note that this is not SAX, merely an event-based XML view" }
{ $see-also read-xml } ;

HELP: pull-xml
{ $class-description "represents the state of a pull-parser for XML. Has one slot, scope, which is a namespace which contains all relevant state information." }
{ $see-also <pull-xml> pull-event pull-elem } ;

HELP: <pull-xml>
{ $values { "pull-xml" "a pull-xml tuple" } }
{ $description "creates an XML pull-based parser which reads from " { $link input-stream } ", executing all initial XML commands to set up the parser." }
{ $see-also pull-xml pull-elem pull-event } ;

HELP: pull-elem
{ $values { "pull" "an XML pull parser" } { "xml-elem/f" "an XML tag, string, or f" } }
{ $description "gets the next XML element from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-event } ;

HELP: pull-event
{ $values { "pull" "an XML pull parser" } { "xml-event/f" "an XML tag event, string, or f" } }
{ $description "gets the next XML event from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-elem } ;

ARTICLE: { "xml" "reading" } "Reading XML"
    "The following words are used to read something into an XML document"
    { $subsection string>xml }
    { $subsection read-xml }
    { $subsection read-xml-chunk }
    { $subsection string>xml-chunk }
    { $subsection file>xml } ;

ARTICLE: { "xml" "events" } "Event-based XML parsing"
    "In addition to DOM-style parsing based around " { $link read-xml } ", the XML module also provides SAX-style event-based parsing. This uses much of the same data structures as normal XML, with the exception of the classes " { $link xml } " and " { $link tag } " and as such, the article " { $vocab-link "xml.data" } " may be useful in learning how to process documents in this way. Other useful words are:"
    { $subsection sax }
    { $subsection opener }
    { $subsection closer }
    { $subsection contained }
    "There is also pull-based parsing to augment the push-parsing of SAX. This is probably easier to use and more logical. It uses the same parsing objects as the above style of parsing, except string elements are always in arrays, for example { \"\" }. Relevant pull-parsing words are:"
    { $subsection <pull-xml> }
    { $subsection pull-xml }
    { $subsection pull-event }
    { $subsection pull-elem } ;

ARTICLE: "xml" "XML parser"
"The " { $vocab-link "xml" } " vocabulary implements the XML 1.0 and 1.1 standards, converting strings of text into XML and vice versa."
    { $subsection { "xml" "reading" } }
    { $subsection { "xml" "events" } }
    { $vocab-subsection "Utilities for processing XML" "xml.utilities" }
    { $vocab-subsection "Writing XML" "xml.writer" }
    { $vocab-subsection "XML parsing errors" "xml.errors" }
    { $vocab-subsection "XML entities" "xml.entities" }
    { $vocab-subsection "XML data types" "xml.data" } ;

IN: xml

ABOUT: "xml"
