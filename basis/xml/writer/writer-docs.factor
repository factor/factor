! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup io strings ;
IN: xml.writer

ABOUT: "xml.writer"

ARTICLE: "xml.writer" "Writing XML"
    "These words are used in implementing prettyprint"
    { $subsection write-xml-chunk }
    "These words are used to print XML normally"
    { $subsection xml>string }
    { $subsection write-xml }
    "These words are used to prettyprint XML"
    { $subsection pprint-xml>string }
    { $subsection pprint-xml>string-but }
    { $subsection pprint-xml }
    { $subsection pprint-xml-but } ;

HELP: write-xml-chunk
{ $values { "object" "an XML element" } }
{ $description "writes an XML element to " { $link output-stream } "." }
{ $see-also write-xml-chunk write-xml } ;

HELP: xml>string
{ $values { "xml" "an xml document" } { "string" "a string" } }
{ $description "converts an XML document into a string" }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

HELP: pprint-xml>string
{ $values { "xml" "an xml document" } { "string" "a string" } }
{ $description "converts an XML document into a string in a prettyprinted form." }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

HELP: write-xml
{ $values { "xml" "an XML document" } }
{ $description "prints the contents of an XML document to " { $link output-stream } "." }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

HELP: pprint-xml
{ $values { "xml" "an XML document" } }
{ $description "prints the contents of an XML document to " { $link output-stream } " in a prettyprinted form." }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

HELP: pprint-xml-but
{ $values { "xml" "an XML document" } { "sensitive-tags" "a sequence of names" } }
{ $description "Prettyprints an XML document, leaving the whitespace of the tags with names in sensitive-tags intact." }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

HELP: pprint-xml>string-but
{ $values { "xml" "an XML document" } { "sensitive-tags" "a sequence of names" } { "string" string } }
{ $description "Prettyprints an XML document, returning the result as a string and leaving the whitespace of the tags with names in sensitive-tags intact." }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" } ;

{ xml>string write-xml pprint-xml pprint-xml>string pprint-xml>string-but pprint-xml-but } related-words

