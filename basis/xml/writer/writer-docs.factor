! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io strings xml.data ;
IN: xml.writer

ABOUT: "xml.writer"

ARTICLE: "xml.writer" "Writing XML"
"These words are used to print XML preserving whitespace in text nodes:"
{ $subsections
    write-xml
    xml>string
}
"These words are used to prettyprint XML:"
{ $subsections
    pprint-xml>string
    pprint-xml
}
"Certain variables can be changed to manipulate prettyprinting:"
{ $subsections
    sensitive-tags
    indenter
}
"All of these words operate on arbitrary pieces of XML: they can take as input XML documents, comments, tags, strings (text nodes), XML chunks, etc." ;

HELP: xml>string
{ $values { "xml" xml } { "string" string } }
{ $description "This converts an XML document " { $snippet "xml" } " into a "
{ $link string } ". It can also be used to convert any piece of XML to a string, eg an "
{ $link xml-chunk } " or " { $link comment } "." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: pprint-xml>string
{ $values { "xml" xml } { "string" string } }
{ $description "Converts an XML document into a " { $link string } " in a prettyprinted form." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: write-xml
{ $values { "xml" xml } }
{ $description "Prints the contents of the XML document to " { $link output-stream } "." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: pprint-xml
{ $values { "xml" xml } }
{ $description "Prints the contents of the XML document to the "
{ $link output-stream } " in a prettyprinted form." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. Whitespace is also not preserved." } ;

{ xml>string write-xml pprint-xml pprint-xml>string } related-words

HELP: indenter
{ $var-description "Contains the string used for indentation in the XML prettyprinter. For example, to print an XML document using " { $snippet "%%%%" } " for indentation, you can do the following:" }
{ $example "USING: xml.syntax xml.writer namespaces ;
[XML <foo>bar</foo> XML] \"%%%%\" indenter [ pprint-xml ] with-variable " "
<foo>
%%%%bar
</foo>" } ;

HELP: sensitive-tags
{ $var-description "Contains a sequence of " { $link name } "s where whitespace should be considered significant for prettyprinting purposes. The sequence can contain " { $link string } "s in place of names. For example, to preserve whitespace inside a " { $snippet "pre" } " tag:" }
{ $example "USING: xml.syntax xml.writer namespaces ;
[XML <!DOCTYPE html> <html> <head> <title> something</title></head><body><pre>bing
bang
   bong</pre></body></html> XML] { \"pre\" } sensitive-tags [ pprint-xml ] with-variable"
"
<!DOCTYPE html>
<html>
  <head>
    <title>
      something
    </title>
  </head>
  <body>
    <pre>bing
bang
   bong</pre>
  </body>
</html>" } ;
